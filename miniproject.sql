CREATE DATABASE IF NOT EXISTS social_network;
USE social_network;

-- =========================
-- 1. Bảng Users
-- =========================
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- 2. Bảng Posts
-- =========================
CREATE TABLE Posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_posts_users
        FOREIGN KEY (user_id)
        REFERENCES Users(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- =========================
-- 3. Bảng Comments
-- =========================
CREATE TABLE Comments (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_comments_posts
        FOREIGN KEY (post_id)
        REFERENCES Posts(post_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_comments_users
        FOREIGN KEY (user_id)
        REFERENCES Users(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- =========================
-- 4. Bảng Friends
-- =========================
CREATE TABLE Friends (
    user_id INT NOT NULL,
    friend_id INT NOT NULL,
    status VARCHAR(20),

    PRIMARY KEY (user_id, friend_id),

    CONSTRAINT fk_friends_user
        FOREIGN KEY (user_id)
        REFERENCES Users(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_friends_friend
        FOREIGN KEY (friend_id)
        REFERENCES Users(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT chk_friend_status
        CHECK (status IN ('pending', 'accepted'))
);

-- =========================
-- 5. Bảng Likes
-- =========================
CREATE TABLE Likes (
    user_id INT NOT NULL,
    post_id INT NOT NULL,

    PRIMARY KEY (user_id, post_id),

    CONSTRAINT fk_likes_users
        FOREIGN KEY (user_id)
        REFERENCES Users(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_likes_posts
        FOREIGN KEY (post_id)
        REFERENCES Posts(post_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- =========================
-- USERS
-- =========================
INSERT INTO Users(username, password, email)
VALUES
('tai01', '123456', 'tai01@gmail.com'),
('minh02', '123456', 'minh02@gmail.com'),
('an03', '123456', 'an03@gmail.com'),
('linh04', '123456', 'linh04@gmail.com'),
('khoa05', '123456', 'khoa05@gmail.com');

-- =========================
-- POSTS
-- =========================
INSERT INTO Posts(user_id, content)
VALUES
(1, 'Hom nay troi dep'),
(2, 'Dang hoc MySQL'),
(3, 'Code SQL met qua'),
(4, 'Di uong tra sua'),
(5, 'Hoc database vui phết');

-- =========================
-- COMMENTS
-- =========================
INSERT INTO Comments(post_id, user_id, content)
VALUES
(1, 2, 'Dep that'),
(2, 3, 'MySQL kho vai'),
(3, 4, 'Co gang len'),
(4, 5, 'Cho xin dia chi quan'),
(5, 1, 'Dung roi');

-- =========================
-- FRIENDS
-- =========================
INSERT INTO Friends(user_id, friend_id, status)
VALUES
(1, 2, 'accepted'),
(1, 3, 'pending'),
(2, 4, 'accepted'),
(3, 5, 'pending'),
(4, 5, 'accepted');

-- =========================
-- LIKES
-- =========================
INSERT INTO Likes(user_id, post_id)
VALUES
(1, 2),
(2, 1),
(3, 4),
(4, 5),
(5, 3);

-- REQ-01: Hiển thị hồ sơ người dùng an toàn
CREATE VIEW vw_UserInfo AS
SELECT user_id,username,created_at,email FROM Users ;

-- REQ-02: Báo cáo tương tác bài viết
CREATE VIEW vw_PostStatistics AS
SELECT 
		p.post_id ,
        p.content as 'Nội dung bài viết',
        u.username as 'Nguoi đăng',
        count(distinct l.user_id) as 'Tổng like', -- ĐẾM distinct TRÁNH TRÙNG LẶP
        count(distinct c.comment_id) as 'Tổng comment'
FROM posts p
LEFT JOIN users u
ON p.user_id = u.user_id
LEFT JOIN likes l
ON l.post_id = p.post_id
LEFT JOIN comments c
ON c.post_id = p.post_id
GROUP BY -- NHÓM LẠI 
		p.post_id ,
        p.content ,
        u.username;
SELECT * FROM vw_PostStatistics;

-- REQ-03: Đăng ký người dùng mới 
DELIMITER $$
	CREATE PROCEDURE RegisterUser( p_user_name VARCHAR(50), p_password VARCHAR(20), p_email VARCHAR(255)  )
    BEGIN
    
    IF EXISTS ( SELECT 1
    FROM users
    WHERE email = p_email
    ) THEN
		 SIGNAL SQLSTATE '45000'
		 SET MESSAGE_TEXT = 'Email da duoc su dung';
	ELSE 
		INSERT INTO users(username,pasword,email)
        VALUES (p_user_name,p_password,p_email);
        
	END IF;
    END;
$$
DELIMITER ; 
		
DELIMITER $$

CREATE PROCEDURE CreatePost (
    IN p_user_id INT,
    IN p_content TEXT,
    OUT p_post_id INT
)
BEGIN

    -- Thêm bài viết mới
    INSERT INTO Posts(user_id, content)
    VALUES (p_user_id, p_content);

    -- Lấy post_id vừa tạo
    SET p_post_id = LAST_INSERT_ID();

END $$

DELIMITER ;
-- REQ-04: Đăng bài viết mới
DELIMITER $$

CREATE PROCEDURE CreatePost (
    IN p_user_id INT,
    IN p_content TEXT,
    OUT p_post_id INT
)
BEGIN

    -- Thêm bài viết mới
    INSERT INTO Posts(user_id, content)
    VALUES (p_user_id, p_content);

    -- Lấy post_id vừa tạo
    SET p_post_id = LAST_INSERT_ID();

END $$

DELIMITER ;
CALL CreatePost(
    1,
    'Hom nay hoc Stored Procedure',
    @new_post_id
);
-- REQ-05: Lấy danh sách bạn bè phân trang 
DELIMITER $$

CREATE PROCEDURE GetFriendList (
    IN p_user_id INT,
    IN p_limit INT,
    IN p_offset INT
)
BEGIN

    SELECT 
        u.username,
        u.email
    FROM Friends f
    JOIN Users u
        ON f.friend_id = u.user_id
    WHERE f.user_id = p_user_id
        AND f.status = 'accepted'
    LIMIT p_limit OFFSET p_offset;

END $$

DELIMITER ;
CALL GetFriendList(1, 5, 5);

-- REQ-06: Tối ưu hóa Newsfeed

CREATE INDEX idx_post_created_at
ON Posts(created_at); 
SELECT *
FROM Posts
ORDER BY created_at DESC;


-- RE07 Xóa dữ liệu phân tầng (Cascade Delete)
ALTER TABLE posts
ADD CONSTRAINT fk_posts_user
FOREIGN KEY (user_id)
REFERENCES users(user_id)
ON DELETE CASCADE;


ALTER TABLE comments
ADD CONSTRAINT fk_comments_user
FOREIGN KEY (user_id)
REFERENCES users(user_id)
ON DELETE CASCADE;


ALTER TABLE likes
ADD CONSTRAINT fk_likes_user
FOREIGN KEY (user_id)
REFERENCES users(user_id)
ON DELETE CASCADE;

ALTER TABLE likes
ADD CONSTRAINT fk_likes_post
FOREIGN KEY (post_id)
REFERENCES posts(post_id)
ON DELETE CASCADE;


ALTER TABLE friends
ADD CONSTRAINT fk_friends_user
FOREIGN KEY (user_id)
REFERENCES users(user_id)
ON DELETE CASCADE;

ALTER TABLE friends
ADD CONSTRAINT fk_friends_friend
FOREIGN KEY (friend_id)
REFERENCES users(user_id)
ON DELETE CASCADE;