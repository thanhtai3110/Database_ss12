CREATE DATABASE StudentDB;
USE StudentDB;

-- 1. Bảng Khoa
CREATE TABLE Department (
    DeptID VARCHAR(5) PRIMARY KEY,
    DeptName VARCHAR(50) NOT NULL
);

-- 2. Bảng SinhVien
CREATE TABLE Student (
    StudentID VARCHAR(6) PRIMARY KEY,
    FullName VARCHAR(50),
    Gender VARCHAR(10),
    BirthDate DATE,
    DeptID VARCHAR(5),
    FOREIGN KEY (DeptID) REFERENCES Department(DeptID)
);

-- 3. Bảng MonHoc
CREATE TABLE Course (
    CourseID VARCHAR(6) PRIMARY KEY,
    CourseName VARCHAR(50),
    Credits INT
);

-- 4. Bảng DangKy
CREATE TABLE Enrollment (
    StudentID VARCHAR(6),
    CourseID VARCHAR(6),
    Score DECIMAL(4,2), 
    PRIMARY KEY (StudentID, CourseID),
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID)
);

-- Chèn dữ liệu mẫu
INSERT INTO Department VALUES
('IT','Information Technology'),
('BA','Business Administration'),
('ACC','Accounting');

INSERT INTO Student VALUES
('S00001','Nguyen An','Male','2003-05-10','IT'),
('S00002','Tran Binh','Male','2003-06-15','IT'),
('S00003','Le Hoa','Female','2003-08-20','BA'),
('S00004','Pham Minh','Male','2002-12-12','ACC'),
('S00005','Vo Lan','Female','2003-03-01','IT'),
('S00006','Do Hung','Male','2002-11-11','BA'),
('S00007','Nguyen Mai','Female','2003-07-07','ACC'),
('S00008','Tran Phuc','Male','2003-09-09','IT');

INSERT INTO Course VALUES
('C00001','Database Systems',3),
('C00002','Data Structures',4),
('C00003','Marketing Basics',3),
('C00004','Financial Accounting',3);

INSERT INTO Enrollment VALUES
('S00001','C00001',8.5),
('S00002','C00001',9.0),
('S00005','C00001',7.5),
('S00008','C00001',9.5),
('S00001','C00002',8.0),
('S00002','C00002',7.0),
('S00005','C00002',8.8),
('S00003','C00003',7.5),
('S00006','C00003',8.2),
('S00004','C00004',6.5),
('S00007','C00004',7.8);

-- Câu 1
CREATE VIEW ViewStudentBasic AS
SELECT  s.StudentID , s.FullName, d.DeptName
FROM Student s
INNER JOIN Department d
ON d.DeptID = s.DeptID ;
SELECT * FROM ViewStudentBasic;

-- Câu 2
CREATE INDEX idxFullName ON Student(FullName);

-- Câu 3
DELIMITER $$
	CREATE PROCEDURE GetStudentsIT ()
    BEGIN
    SELECT  s.StudentID , s.FullName, d.DeptName FROM Student s
    JOIN Department d
    ON d.DeptID = s.DeptID 
    WHERE d.DeptName = 'Information Technology';
    END;
$$
DELIMITER ;
CALL GetStudentsIT ();
-- Câu 4
CREATE VIEW  ViewStudentCountByDept AS
SELECT d.DeptName ,
		COUNT(s.StudentID) AS TotalStudents
FROM Department d
	LEFT JOIN Student s
ON  d.DeptID = s.DeptID
GROUP BY d.DeptName ;

SELECT * FROM ViewStudentcountByDept WHERE TotalStudents = (SELECT MAX(TotalStudents) FROM ViewStudentcountByDept) ;
-- Câu 5
DELIMITER $$
	CREATE PROCEDURE GetTopScoreStudent (IN varCourseID VARCHAR(6) )
		BEGIN
            SELECT 
        s.StudentID,
        s.FullName,
        e.Score
    FROM Enrollment e
    JOIN Student s ON e.StudentID = s.StudentID
    WHERE e.CourseID = varCourseID
	AND e.Score = (
          SELECT MAX(Score)
          FROM Enrollment
          WHERE CourseID = varCourseID
      );
        END;
$$
DELIMITER ;
CALL GetTopScoreStudent ('C00001');

-- Câu 6

CREATE VIEW ViewITEnrollmentDB AS
SELECT 
    e.StudentID,
    e.CourseID,
    e.Score
FROM Enrollment e
JOIN Student s ON e.StudentID = s.StudentID
JOIN Department d ON s.DeptID = d.DeptID
WHERE d.DeptName = 'Information Technology'
  AND e.CourseID = 'C00001'
WITH CHECK OPTION;


