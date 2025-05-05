CREATE DATABASE QLDIEMHS_FINAL

-- Dùng cơ sở dữ liệu
USE QLDIEMHS_FINAL

-- Tạo bảng LOP (Lớp học)
CREATE TABLE LOP (
    MaLop CHAR(10) NOT NULL PRIMARY KEY,  -- Mã lớp
    TenLop NVARCHAR(100) NOT NULL,        -- Tên lớp
    SoLuong INT NOT NULL                  -- Số lượng học sinh trong lớp
);

-- Tạo bảng HOCSINH (Học sinh)
CREATE TABLE HOCSINH (
    MaHS CHAR(10) NOT NULL PRIMARY KEY,   -- Mã học sinh
    TenHS NVARCHAR(100) NOT NULL,         -- Tên học sinh
    NgaySinh DATE,                        -- Ngày sinh
    GioiTinh NVARCHAR(10) NOT NULL,       -- Giới tính
    DiaChi NVARCHAR(200) NOT NULL,        -- Địa chỉ
    Sdt NVARCHAR(15),                     -- Số điện thoại
    MaLop CHAR(10),                       -- Mã lớp học sinh
	ViPham INT                            -- Số vi phạm để đánh giá hạnh kiểm
);

-- Tạo bảng MONHOC (Môn học)
CREATE TABLE MONHOC (
    MaMon CHAR(10) PRIMARY KEY,           -- Mã môn học
    TenMon NVARCHAR(100) NOT NULL         -- Tên môn học
);

-- Tạo bảng HOCKY (Học kỳ)
CREATE TABLE HOCKY (
    MaHocKy CHAR(10) NOT NULL PRIMARY KEY,    -- Mã học kỳ
    TenHocKy NVARCHAR(50),                    -- Tên học kỳ
    NamHoc NVARCHAR(20) NOT NULL,             -- Năm học
    ThoiGianBatDau DATE,                      -- Thời gian bắt đầu học kỳ
    ThoiGianKetThuc DATE                      -- Thời gian kết thúc học kỳ
);

-- Tạo bảng DIEM (Điểm học sinh)
CREATE TABLE DIEM (
    MaHS CHAR(10) NOT NULL,                    -- Mã học sinh (Foreign Key)
    MaMon CHAR(10) NOT NULL,                   -- Mã môn học (Foreign Key)
    MaHocKy CHAR(10) NOT NULL,                 -- Mã học kỳ (Foreign Key)
    DiemMieng FLOAT,                           -- Điểm miệng
    Diem15p FLOAT,                             -- Điểm 15 phút
    Diem1tiet FLOAT,                           -- Điểm 1 tiết
    DiemThi FLOAT,                             -- Điểm thi
    DiemTBMon FLOAT NULL,                      -- Điểm trung bình môn
    CONSTRAINT PK_DIEM PRIMARY KEY (MaHS, MaMon, MaHocKy)  -- Khóa chính
);

-- Tạo bảng HOCBONG (Học bổng)
CREATE TABLE HOCBONG (
    MaHocBong CHAR(10) PRIMARY KEY,            -- Mã học bổng
    TenHocBong NVARCHAR(100) NOT NULL,         -- Tên học bổng
    GiaTri FLOAT NOT NULL,                     -- Giá trị học bổng
    DieuKien NVARCHAR(255),                    -- Điều kiện học bổng
    LoaiHocBong NVARCHAR(50),                  -- Loại học bổng
    NguonCap NVARCHAR(100),                    -- Nguồn cấp học bổng
    GhiChu NVARCHAR(255)                       -- Ghi chú
);


-- Liên kết bảng HOCSINH với LOP
ALTER TABLE HOCSINH
ADD CONSTRAINT FK_HOCSINH_LOP
FOREIGN KEY (MaLop) REFERENCES LOP(MaLop);

-- Liên kết bảng DIEM với HOCSINH
ALTER TABLE DIEM
ADD CONSTRAINT FK_DIEM_HOCSINH
FOREIGN KEY (MaHS) REFERENCES HOCSINH(MaHS);

-- Liên kết bảng DIEM với MONHOC
ALTER TABLE DIEM
ADD CONSTRAINT FK_DIEM_MONHOC
FOREIGN KEY (MaMon) REFERENCES MONHOC(MaMon);

-- Liên kết bảng DIEM với HOCKY
ALTER TABLE DIEM
ADD CONSTRAINT FK_DIEM_HOCKY
FOREIGN KEY (MaHocKy) REFERENCES HOCKY(MaHocKy);



-- Tạo lại View v_KETQUA sau khi đã xóa bảng KETQUA
CREATE VIEW v_KETQUA AS
SELECT
    HOCSINH.MaHS,                 
    HOCSINH.TenHS,      
	HOCKY.MaHocKy,
    HOCKY.TenHocKy,
    AVG(DIEM.DiemTBMon) AS DiemTB,      
    CASE
        WHEN AVG(DIEM.DiemTBMon) >= 8.5 THEN N'Giỏi'
        WHEN AVG(DIEM.DiemTBMon) >= 6.5 THEN N'Khá'
        WHEN AVG(DIEM.DiemTBMon) >= 5.5 THEN N'Trung bình'
        ELSE N'Yếu'
    END AS XepLoai                   
FROM
    HOCSINH,                            
    DIEM,
    HOCKY
WHERE
    HOCSINH.MaHS = DIEM.MaHS         
    AND DIEM.MaHocKy = HOCKY.MaHocKy    
    AND DIEM.DiemTBMon IS NOT NULL      
GROUP BY
    HOCSINH.MaHS,                   
    HOCSINH.TenHS,             
    HOCKY.MaHocKy,                    
    HOCKY.TenHocKy;                     
GO

SELECT *
FROM v_KETQUA
ORDER BY MaHS, TenHocKy;


-- Tạo lại View v_HANHKIEM sau khi đã xóa bảng HANHKIEM
CREATE VIEW v_HANHKIEM AS
SELECT DISTINCT 
    HOCSINH.MaHS,
    HOCSINH.TenHS,
	HOCKY.MaHocKy,
    HOCKY.TenHocKy,
    HOCSINH.ViPham,
    -- Đánh giá hạnh kiểm học sinh từ số lượt vi phạm
    CASE
        WHEN HOCSINH.ViPham <= 3 THEN N'Tốt'
        WHEN HOCSINH.ViPham > 3 AND HOCSINH.ViPham <= 7 THEN N'Khá'
        ELSE N'Trung bình'
    END AS HanhKiem
FROM 
    HOCSINH,
    HOCKY,
    DIEM
WHERE 
    HOCSINH.MaHS = DIEM.MaHS 
    AND DIEM.MaHocKy = HOCKY.MaHocKy;

SELECT * FROM v_HANHKIEM

SELECT * FROM v_KETQUA


---- Các Trigger cần bật trước khi insert values ----

---- Liên hệ với phần 1: Quản lý thông tin học sinh ----
﻿-- 1.1: Tạo trigger cho cập nhật số lượng học sinh 
CREATE TRIGGER Trg_CapNhatSoLuongLop ON HOCSINH FOR INSERT, DELETE, UPDATE
AS
BEGIN
    UPDATE LOP
    SET SoLuong = SoLuong - (SELECT COUNT(*) FROM deleted WHERE LOP.MaLop = deleted.MaLop)
    FROM LOP, deleted
	WHERE LOP.MaLop = deleted.MaLop;

    UPDATE LOP
	SET LOP.SoLuong = LOP.SoLuong + (SELECT COUNT(*) FROM inserted WHERE LOP.MaLop = inserted.MaLop)
	FROM LOP, inserted
	WHERE LOP.MaLop = inserted.MaLop
END
GO

-- Bật/Tắt Trigger 1.1
ENABLE TRIGGER Trg_CapNhatSoLuongLop ON HOCSINH;
DISABLE TRIGGER Trg_CapNhatSoLuongLop ON HOCSINH;


---- Liên hệ tới phần 3: Tính điểm trung bình của học sinh ----

--3.1: Trigger Tinh DiemTBMon
CREATE TRIGGER TRG_TinhDiemTBMon
ON DIEM -- Không dùng dbo.
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM inserted)
    BEGIN
        UPDATE DIEM 
        SET DiemTBMon = (
                            ISNULL(inserted.DiemMieng, 0) * 0.1 +
                            ISNULL(inserted.Diem15p, 0) * 0.1 +
                            ISNULL(inserted.Diem1tiet, 0) * 0.3 +
                            ISNULL(inserted.DiemThi, 0) * 0.5
                        )
        FROM inserted
        WHERE DIEM.MaHS = inserted.MaHS
          AND DIEM.MaMon = inserted.MaMon
          AND DIEM.MaHocKy = inserted.MaHocKy;
    END
END;
GO

-- Bật/Tắt Trigger 3.2
ENABLE TRIGGER TRG_TinhDiemTBMon ON DIEM;
DISABLE TRIGGER TRG_TinhDiemTBMon ON DIEM




---- Thêm giá trị cho các bảng ----

-- Thêm giá trị cho bảng LOP
-- Trường SoLuong ban đầu là 0 để sau khi thêm học sinh ta sẽ có sẵn trigger để thêm số lượng rồi.
-- Lưu ý: Insert values cho bảng LOP trước bảng HOCSINH (Không insert đồng thời)
INSERT INTO LOP VALUES ('L01', N'Lớp 10A', 0);
INSERT INTO LOP VALUES ('L02', N'Lớp 10B', 0);
INSERT INTO LOP VALUES ('L03', N'Lớp 10C', 0);
INSERT INTO LOP VALUES ('L04', N'Lớp 11A', 0);
INSERT INTO LOP VALUES ('L05', N'Lớp 11B', 0);
INSERT INTO LOP VALUES ('L06', N'Lớp 12A', 0);
INSERT INTO LOP VALUES ('L07', N'Lớp 12B', 0);
INSERT INTO LOP VALUES ('L08', N'Lớp 12C', 0);
INSERT INTO LOP VALUES ('L09', N'Lớp 11C', 0);
INSERT INTO LOP VALUES ('L10', N'Lớp 10D', 0);

SELECT * FROM LOP

-- Thêm giá trị cho bảng HOCSINH
INSERT INTO HOCSINH VALUES ('HS001', N'Nguyễn Văn An', '2008-05-12', N'Nam', N'Hà Nội', '0983456789', 'L01', 0);
INSERT INTO HOCSINH VALUES ('HS002', N'Lê Thị Bình', '2008-07-25', N'Nữ', N'Hà Nội', '0987654321', 'L01', 0);
INSERT INTO HOCSINH VALUES ('HS003', N'Phạm Văn Cường', '2008-03-10', N'Nam', N'Hà Nội', '0912345678', 'L01', 1);
INSERT INTO HOCSINH VALUES ('HS004', N'Trần Thị Dung', '2008-12-05', N'Nữ', N'Hà Nội', '0923456789', 'L01', 0);
INSERT INTO HOCSINH VALUES ('HS005', N'Hoàng Văn Ðức', '2008-01-15', N'Nam', N'Hà Nội', '0934567890', 'L01', 0);

-- Lớp 10B (L02)
INSERT INTO HOCSINH VALUES ('HS006', N'Vũ Thị Hà', '2008-06-20', N'Nữ', N'Hà Nội', '0945678901', 'L02', 0);
INSERT INTO HOCSINH VALUES ('HS007', N'Đỗ Văn Hoàng', '2008-09-18', N'Nam', N'Hà Nội', '0956789012', 'L02', 1);
INSERT INTO HOCSINH VALUES ('HS008', N'Nguyễn Thị Lan', '2008-11-27', N'Nữ', N'Hà Nội', '0967890123', 'L02', 0);
INSERT INTO HOCSINH VALUES ('HS009', N'Trần Văn Minh', '2008-02-14', N'Nam', N'Hà Nội', '0978901234', 'L02', 2);
INSERT INTO HOCSINH VALUES ('HS010', N'Lê Thị Ngọc', '2008-04-30', N'Nữ', N'Hà Nội', '0989012345', 'L02', 0);

-- Lớp 11A (L04)
INSERT INTO HOCSINH VALUES ('HS011', N'Phạm Văn Phong', '2007-08-11', N'Nam', N'Hà Nội', '0990123456', 'L04', 0);
INSERT INTO HOCSINH VALUES ('HS012', N'Hoàng Thị Quỳnh', '2007-10-22', N'Nữ', N'Hà Nội', '0901234567', 'L04', 1);
INSERT INTO HOCSINH VALUES ('HS013', N'Vũ Văn Sơn', '2007-01-19', N'Nam', N'Hà Nội', '0912345678', 'L04', 1);
INSERT INTO HOCSINH VALUES ('HS014', N'Đỗ Thị Thảo', '2007-05-09', N'Nữ', N'Hà Nội', '0923456789', 'L04', 0);
INSERT INTO HOCSINH VALUES ('HS015', N'Nguyễn Văn Ứng', '2007-07-31', N'Nam', N'Hà Nội', '0934567890', 'L04', 0);

-- Lớp 11B (L05)
INSERT INTO HOCSINH VALUES ('HS016', N'Trần Thị Vân', '2007-12-12', N'Nữ', N'Hà Nội', '0945678901', 'L05', 0);
INSERT INTO HOCSINH VALUES ('HS017', N'Lê Văn Xuân', '2007-04-06', N'Nam', N'Hà Nội', '0956789012', 'L05', 2);
INSERT INTO HOCSINH VALUES ('HS018', N'Phạm Thị Yến', '2007-06-29', N'Nữ', N'Hà Nội', '0967890123', 'L05', 0);
INSERT INTO HOCSINH VALUES ('HS019', N'Hoàng Văn Anh', '2007-02-14', N'Nam', N'Hà Nội', '0978901234', 'L05', 1);
INSERT INTO HOCSINH VALUES ('HS020', N'Vũ Thị Bích', '2007-11-25', N'Nữ', N'Hà Nội', '0989012345', 'L05', 0);

-- Lớp 12A (L06)
INSERT INTO HOCSINH VALUES ('HS021', N'Đỗ Văn Cường', '2006-09-17', N'Nam', N'Hà Nội', '0990123456', 'L06', 0);
INSERT INTO HOCSINH VALUES ('HS022', N'Nguyễn Thị Dung', '2006-03-28', N'Nữ', N'Hà Nội', '0901234567', 'L06', 0);
INSERT INTO HOCSINH VALUES ('HS023', N'Trần Văn Hải', '2006-05-16', N'Nam', N'Hà Nội', '0912345678', 'L06', 1);
INSERT INTO HOCSINH VALUES ('HS024', N'Lê Thị Hoa', '2006-08-13', N'Nữ', N'Hà Nội', '0923456789', 'L06', 0);
INSERT INTO HOCSINH VALUES ('HS025', N'Phạm Văn Khánh', '2006-10-20', N'Nam', N'Hà Nội', '0934567890', 'L06', 2);

-- Lớp 12B (L07)
INSERT INTO HOCSINH VALUES ('HS026', N'Hoàng Thị Lan', '2006-01-04', N'Nữ', N'Hà Nội', '0945678901', 'L07', 0);
INSERT INTO HOCSINH VALUES ('HS027', N'Vũ Văn Minh', '2006-04-11', N'Nam', N'Hà Nội', '0956789012', 'L07', 1);
INSERT INTO HOCSINH VALUES ('HS028', N'Đỗ Thị Ngọc', '2006-07-22', N'Nữ', N'Hà Nội', '0967890123', 'L07', 0);
INSERT INTO HOCSINH VALUES ('HS029', N'Nguyễn Văn Phong', '2006-11-30', N'Nam', N'Hà Nội', '0978901234', 'L07', 0);
INSERT INTO HOCSINH VALUES ('HS030', N'Trần Thị Quỳnh', '2006-02-28', N'Nữ', N'Hà Nội', '0989012345', 'L07', 1);


SELECT * FROM HOCSINH


-- Thêm giá trị cho bảng MONHOC
INSERT INTO MONHOC VALUES ('M01', N'Toán');
INSERT INTO MONHOC VALUES ('M02', N'Lý');
INSERT INTO MONHOC VALUES ('M03', N'Hóa');
INSERT INTO MONHOC VALUES ('M04', N'Văn');
INSERT INTO MONHOC VALUES ('M05', N'Sử');
INSERT INTO MONHOC VALUES ('M06', N'Tiếng Anh');
INSERT INTO MONHOC VALUES ('M07', N'GDCD');
INSERT INTO MONHOC VALUES ('M08', N'Tin học');
INSERT INTO MONHOC VALUES ('M09', N'Giáo dục công dân');
INSERT INTO MONHOC VALUES ('M10', N'Ngoại ngữ');

SELECT * FROM MONHOC

-- Thêm giá trị cho bảng HOCKY
INSERT INTO HOCKY VALUES ('HK01', N'Học kỳ 1', N'2021-2022', '2021-08-01', '2021-12-31');
INSERT INTO HOCKY VALUES ('HK02', N'Học kỳ 2', N'2021-2022', '2022-01-01', '2022-05-31');
INSERT INTO HOCKY VALUES ('HK03', N'Học kỳ 1', N'2022-2023', '2022-08-01', '2022-12-31');
INSERT INTO HOCKY VALUES ('HK04', N'Học kỳ 2', N'2022-2023', '2023-01-01', '2023-05-31');
INSERT INTO HOCKY VALUES ('HK05', N'Học kỳ 1', N'2023-2024', '2023-08-01', '2023-12-31');
INSERT INTO HOCKY VALUES ('HK06', N'Học kỳ 2', N'2023-2024', '2024-01-01', '2024-05-31');
INSERT INTO HOCKY VALUES ('HK07', N'Học kỳ 1', N'2024-2025', '2024-08-01', '2024-12-31');
INSERT INTO HOCKY VALUES ('HK08', N'Học kỳ 2', N'2024-2025', '2025-01-01', '2025-05-31');
INSERT INTO HOCKY VALUES ('HK09', N'Học kỳ 1', N'2025-2026', '2025-08-01', '2025-12-31');
INSERT INTO HOCKY VALUES ('HK10', N'Học kỳ 2', N'2025-2026', '2026-01-01', '2026-05-31');

SELECT * FROM HOCKY


-- Thêm giá trị cho bảng HOCBONG
-- Trạng thái nhận học bổng cũng để trống để cập nhật sau
INSERT INTO HOCBONG VALUES ('HB001', N'Học bổng Giỏi', 3000000, N'DTB >= 8.5', N'Học bổng', N'Trường THPT Yên Hòa', N'');
INSERT INTO HOCBONG VALUES ('HB002', N'Học bổng Khuyến khích', 1500000, N'DTB >= 7.5', N'Học bổng', N'Trường THPT Lý Thái Tổ', N'');
INSERT INTO HOCBONG VALUES ('HB003', N'Học bổng Học tập', 2500000, N'DTB >= 8.0', N'Học bổng', N'Trường THPT Hà Nội - Amsterdam', N'');
INSERT INTO HOCBONG VALUES ('HB004', N'Học bổng Toàn phần', 5000000, N'DTB >= 9.0', N'Học bổng', N'Trường THPT Chuyên Bắc Giang', N'');
INSERT INTO HOCBONG VALUES ('HB005', N'Học bổng Khuyến học', 3000000, N'DTB >= 7.0', N'Học bổng', N'Doanh nghiệp C', N'');

SELECT * FROM HOCBONG


-- Thêm giá trị cho bảng DIEM
-- Điểm trung bình cũng để mặc định giá trị là NULL để cập nhật sau (Ghi rõ công thức tính điểm trung bình)
-- Thêm dữ liệu vào bảng DIEM (DiemTB sẽ để NULL)
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS001', 'M01', 'HK01', 8.5, 9.0, 8.0, 8.5);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS001', 'M02', 'HK01', 7.5, 8.0, 7.0, 7.5);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS001', 'M03', 'HK01', 8.0, 8.5, 7.5, 8.0);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS001', 'M04', 'HK01', 7.0, 7.5, 8.0, 7.5);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS001', 'M06', 'HK01', 8.5, 9.0, 8.5, 9.0);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS001', 'M09', 'HK01', 9.0, 8.5, 9.0, 8.5);

-- Lê Thị Bình (HS002)
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS002', 'M01', 'HK01', 9.0, 9.5, 9.0, 9.5);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS002', 'M02', 'HK01', 8.5, 9.0, 8.5, 9.0);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS002', 'M03', 'HK01', 9.0, 8.5, 9.0, 8.5);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS002', 'M04', 'HK01', 9.5, 9.0, 9.5, 9.0);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS002', 'M06', 'HK01', 8.0, 8.5, 8.0, 8.5);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS002', 'M09', 'HK01', 9.0, 9.5, 9.0, 9.5);

-- Phạm Văn Cường (HS003)
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS003', 'M01', 'HK01', 7.0, 7.5, 7.0, 8.0);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS003', 'M02', 'HK01', 6.5, 7.0, 6.5, 7.0);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS003', 'M03', 'HK01', 7.5, 7.0, 7.5, 8.0);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS003', 'M04', 'HK01', 8.0, 7.5, 8.0, 7.5);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS003', 'M06', 'HK01', 6.0, 6.5, 6.0, 7.0);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS003', 'M09', 'HK01', 7.0, 7.5, 7.0, 8.0);

-- Điểm học sinh lớp 11A (L04) - Học kỳ 1
-- Phạm Văn Phong (HS011)
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS011', 'M01', 'HK01', 7.0, 7.5, 7.0, 7.5);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS011', 'M02', 'HK01', 8.0, 7.5, 8.0, 7.5);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS011', 'M03', 'HK01', 7.5, 8.0, 7.5, 8.0);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS011', 'M05', 'HK01', 7.0, 7.5, 7.0, 7.5);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS011', 'M07', 'HK01', 8.5, 8.0, 8.5, 8.0);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS011', 'M08', 'HK01', 9.0, 8.5, 9.0, 8.5);

-- Hoàng Thị Quỳnh (HS012)
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS012', 'M01', 'HK01', 9.5, 9.0, 9.5, 9.0);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS012', 'M02', 'HK01', 9.0, 9.5, 9.0, 9.5);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS012', 'M03', 'HK01', 8.5, 9.0, 8.5, 9.0);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS012', 'M05', 'HK01', 8.0, 8.5, 8.0, 8.5);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS012', 'M07', 'HK01', 8.5, 8.0, 8.5, 8.0);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS012', 'M08', 'HK01', 9.5, 9.0, 9.5, 9.0);

-- Vũ Văn Sơn (HS013)
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS013', 'M01', 'HK01', 8.0, 8.5, 8.0, 8.5);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS013', 'M02', 'HK01', 7.5, 8.0, 7.5, 8.0);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS013', 'M03', 'HK01', 7.0, 7.5, 7.0, 7.5);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS013', 'M05', 'HK01', 6.5, 7.0, 6.5, 7.0);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS013', 'M07', 'HK01', 7.0, 7.5, 7.0, 7.5);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS013', 'M08', 'HK01', 8.5, 8.0, 8.5, 8.0);

-- Điểm học sinh lớp 12A (L06) - Học kỳ 1
-- Đỗ Văn Cường (HS021)
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS021', 'M01', 'HK01', 8.0, 8.5, 8.0, 8.5);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS021', 'M02', 'HK01', 7.5, 8.0, 7.5, 8.0);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS021', 'M03', 'HK01', 8.5, 8.0, 8.5, 8.0);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS021', 'M04', 'HK01', 7.0, 7.5, 7.0, 7.5);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS021', 'M06', 'HK01', 8.0, 8.5, 8.0, 8.5);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS021', 'M08', 'HK01', 9.0, 9.5, 9.0, 9.5);

-- Nguyễn Thị Dung (HS022)
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS022', 'M01', 'HK01', 9.0, 9.5, 9.0, 9.5);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS022', 'M02', 'HK01', 8.5, 9.0, 8.5, 9.0);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS022', 'M03', 'HK01', 9.0, 8.5, 9.0, 8.5);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS022', 'M04', 'HK01', 8.0, 8.5, 8.0, 8.5);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS022', 'M06', 'HK01', 9.5, 9.0, 9.5, 9.0);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS022', 'M08', 'HK01', 8.0, 8.5, 8.0, 8.5);

-- Trần Văn Hải (HS023)
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS023', 'M01', 'HK01', 7.5, 8.0, 7.5, 8.0);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS023', 'M02', 'HK01', 8.0, 7.5, 8.0, 7.5);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS023', 'M03', 'HK01', 7.0, 7.5, 7.0, 7.5);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS023', 'M04', 'HK01', 6.5, 7.0, 6.5, 7.0);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS023', 'M06', 'HK01', 7.0, 7.5, 7.0, 7.5);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS023', 'M08', 'HK01', 8.5, 8.0, 8.5, 8.0);

-- Thêm dữ liệu điểm HỌC KỲ 2 (2023-2024) - HK02
-- Điểm học sinh lớp 10A (L01) - Học kỳ 2
-- Nguyễn Văn An (HS001)
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS001', 'M01', 'HK02', 8.0, 9.0, 8.5, 9.0); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS001', 'M02', 'HK02', 7.0, 8.5, 7.5, 7.0); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS001', 'M03', 'HK02', 7.5, 8.0, 7.0, 7.5); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS001', 'M04', 'HK02', 8.0, 8.0, 8.5, 8.0);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS001', 'M06', 'HK02', 8.0, 9.5, 8.0, 9.0); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS001', 'M09', 'HK02', 9.5, 8.0, 9.0, 9.0); 

-- Lê Thị Bình (HS002)
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS002', 'M01', 'HK02', 9.5, 9.0, 9.0, 9.5); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS002', 'M02', 'HK02', 9.0, 8.5, 9.0, 9.0); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS002', 'M03', 'HK02', 8.5, 9.0, 8.5, 9.0); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS002', 'M04', 'HK02', 9.0, 9.5, 9.0, 9.5); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS002', 'M06', 'HK02', 8.5, 8.0, 8.5, 8.0); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS002', 'M09', 'HK02', 9.5, 9.0, 9.5, 9.0); 

-- Phạm Văn Cường (HS003)
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS003', 'M01', 'HK02', 7.5, 7.0, 7.5, 7.5);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS003', 'M02', 'HK02', 7.0, 6.5, 7.0, 7.0);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS003', 'M03', 'HK02', 8.0, 7.5, 7.0, 7.5);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS003', 'M04', 'HK02', 8.5, 8.0, 7.5, 8.0);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS003', 'M06', 'HK02', 6.5, 7.0, 6.5, 6.5); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS003', 'M09', 'HK02', 7.5, 7.0, 7.5, 7.5);

-- Điểm học sinh lớp 11A (L04) - Học kỳ 2
-- Phạm Văn Phong (HS011)
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS011', 'M01', 'HK02', 7.5, 7.0, 7.5, 8.0); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS011', 'M02', 'HK02', 8.5, 8.0, 7.5, 8.0); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS011', 'M03', 'HK02', 8.0, 7.5, 8.0, 8.5); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS011', 'M05', 'HK02', 7.5, 7.0, 7.5, 7.0); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS011', 'M07', 'HK02', 8.0, 8.5, 8.0, 8.5); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS011', 'M08', 'HK02', 9.5, 9.0, 8.5, 9.0); 

-- Hoàng Thị Quỳnh (HS012)
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS012', 'M01', 'HK02', 9.0, 9.5, 9.0, 9.5); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS012', 'M02', 'HK02', 9.5, 9.0, 9.5, 9.0); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS012', 'M03', 'HK02', 9.0, 8.5, 9.0, 8.5); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS012', 'M05', 'HK02', 8.5, 8.0, 8.5, 8.0); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS012', 'M07', 'HK02', 9.0, 8.5, 9.0, 8.5);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS012', 'M08', 'HK02', 9.0, 9.5, 9.0, 9.5);  

-- Vũ Văn Sơn (HS013)
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS013', 'M01', 'HK02', 8.5, 8.0, 8.5, 8.0); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS013', 'M02', 'HK02', 8.0, 7.5, 8.0, 7.5); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS013', 'M03', 'HK02', 7.5, 7.0, 7.5, 7.0); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS013', 'M05', 'HK02', 7.0, 6.5, 7.0, 6.5); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS013', 'M07', 'HK02', 7.5, 7.0, 7.5, 7.0); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS013', 'M08', 'HK02', 8.0, 8.5, 8.0, 8.5); 

-- Điểm học sinh lớp 12A (L06) - Học kỳ 2
-- Đỗ Văn Cường (HS021)
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS021', 'M01', 'HK02', 8.5, 8.0, 8.5, 9.0); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS021', 'M02', 'HK02', 8.0, 7.5, 8.0, 8.5); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS021', 'M03', 'HK02', 8.0, 8.5, 8.0, 8.0); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS021', 'M04', 'HK02', 7.5, 7.0, 7.5, 7.0); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS021', 'M06', 'HK02', 8.5, 8.0, 8.5, 8.0); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS021', 'M08', 'HK02', 9.5, 9.0, 9.5, 9.0); 

-- Nguyễn Thị Dung (HS022)
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS022', 'M01', 'HK02', 9.5, 9.0, 9.5, 9.0); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS022', 'M02', 'HK02', 9.0, 8.5, 9.0, 8.5); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS022', 'M03', 'HK02', 8.5, 9.0, 8.5, 9.0);
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS022', 'M04', 'HK02', 8.5, 8.0, 8.5, 8.0); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS022', 'M06', 'HK02', 9.0, 9.5, 9.0, 9.5); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS022', 'M08', 'HK02', 8.5, 8.0, 8.5, 8.0); 

-- Trần Văn Hải (HS023)
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS023', 'M01', 'HK02', 8.0, 7.5, 8.0, 7.5); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS023', 'M02', 'HK02', 7.5, 8.0, 7.5, 8.0); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS023', 'M03', 'HK02', 7.5, 7.0, 7.5, 7.0); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS023', 'M04', 'HK02', 7.0, 6.5, 7.0, 6.5); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS023', 'M06', 'HK02', 7.5, 7.0, 7.5, 7.0); 
INSERT INTO DIEM (MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES ('HS023', 'M08', 'HK02', 8.0, 8.5, 8.0, 8.5); 

SELECT * FROM LOP;
SELECT * FROM HOCSINH;
SELECT * FROM MONHOC;
SELECT * FROM HOCKY;
SELECT * FROM HOCBONG;
SELECT * FROM DIEM;



---- 1. Quản lý thông tin học sinh ----

-- 1.1: Tạo proc cho thêm học sinh
CREATE PROC sp_THEMHS
	@mahs char(10), @tenhs char(10), @ngaysinh date, 
	@gt nvarchar(10), @dc nvarchar(20), @sdt nvarchar(15), @malop char(10), @vp int
AS
BEGIN
	IF(EXISTS (SELECT * FROM HOCSINH WHERE MAHS = @mahs))
		PRINT N'Mã học sinh đã tồn tại trong hệ thống, không thêm được.'
	ELSE IF (NOT EXISTS (SELECT * FROM LOP WHERE MaLop = @malop))
		PRINT N'Mã lớp không tồn tại trong hệ thống, không thêm được.'
	ELSE IF((SELECT SoLuong FROM LOP WHERE MaLop = @malop) >= 40 )
		PRINT N'Lớp đã đủ học sinh, không thêm được.'
	ELSE
	BEGIN
		INSERT INTO HOCSINH VALUES (@mahs, @tenhs, @ngaysinh, @gt , @dc , @sdt, @malop, @vp);
		PRINT N'Thêm học sinh thành công.'
	END
END

EXEC sp_THEMHS 'HS03', N'Trần Ngọc Hải', '2005-08-12', N'Nam', N'Hà Nam', '0983456909','L03', 0; -- Chạy thử Procedure 1.1


-- 1.2: Tạo proc cho sửa thông tin học sinh
CREATE PROC sp_SuaThongTinHS
	@mahs char(10), @tenhs char(10), @ngaysinh date, 
	@gt nvarchar(10), @dc nvarchar(20), @sdt nvarchar(15), @malop char(10), @vp int
AS
BEGIN
	IF(NOT EXISTS (SELECT * FROM HOCSINH WHERE MaHS = @mahs))
		PRINT N'Mã học sinh không tồn tại trong hệ thống.'
	ELSE IF (NOT EXISTS (SELECT * FROM LOP WHERE MaLop = @malop))
		PRINT N'Mã lớp không tồn tại trong hệ thống.'
	ELSE
	BEGIN
		UPDATE HOCSINH 
		SET
			TenHS = @tenhs, 
			NgaySinh = @ngaysinh, 
			GioiTinh = @gt , 
			DiaChi = @dc , 
			Sdt = @sdt, 
			MaLop = @malop,
			ViPham = @vp
		WHERE MaHS = @mahs;
		PRINT N'Sửa thông tin học sinh thành công.'
	END
END

EXEC sp_SuaThongTinHS 'HS04', N'Trần Ngọc Anh', '2005-08-12', N'Nữ', N'Hà Nội', '0983456909','L01', 0; -- Chạy thử Procedure 1.2


-- 1.3: Tạo proc cho xoá học sinh
ALTER PROC sp_XoaHS @mahs char(10)
AS
BEGIN
	IF(NOT EXISTS (SELECT * FROM HOCSINH WHERE MAHS = @mahs))
		PRINT N'Mã học sinh không tồn tại trong hệ thống.'
	ELSE
	BEGIN -- xoá lần lượt các bảng có ràng buộc dữ liệu
		DELETE v_HANHKIEM  WHERE MaHS = @mahs;
		DELETE DIEM WHERE MaHS = @mahs;
		DELETE v_KETQUA WHERE MaHS = @mahs;
		DELETE DIEM WHERE MaHS = @mahs;
		DELETE HOCSINH WHERE MaHS = @mahs;
		PRINT N'Xoá học sinh thành công.';
	END
END

EXEC sp_XoaHS 'HS100' -- Thử thủ túc xóa học sinh

---- Phần 2: Nhập và cập nhật điểm học sinh ----

-- 2.1: Tạo proc cho nhập điểm
CREATE PROC sp_NhapDiem @MaHS char(10),@MaMon char(10), @MaHocKy char(10), @DiemMieng float, @Diem15p float, @Diem1tiet float, @DiemThi float
AS
BEGIN
	IF (EXISTS (SELECT * FROM DIEM WHERE MaHS = @MaHS AND MaMon = @MaMon AND MaHocKy = @MaHocKy))
		PRINT N'Điểm của học sinh này đã được nhập trước đó.'
	ELSE IF(NOT EXISTS (SELECT * FROM HOCSINH WHERE MaHS = @MaHS))
		PRINT N'Mã học sinh này không tồn tại trong hệ thống.'
	ELSE IF (NOT EXISTS (SELECT * FROM MONHOC WHERE MaMon = @MaMon))
		PRINT N'Mã môn học này không tồn tại trong hệ thống.'
	ELSE IF (NOT EXISTS (SELECT * FROM HOCKY WHERE MaHocKy = @MaHocKy))
		PRINT N'Mã học kỳ này không tồn tại trong hệ thống.'
	ELSE
	BEGIN
		INSERT INTO DIEM(MaHS, MaMon, MaHocKy, DiemMieng, Diem15p, Diem1tiet, DiemThi) VALUES (@MaHS, @MaMon, @MaHocKy, @DiemMieng, @Diem15p, @Diem1tiet, @DiemThi);
		PRINT N'Nhập điểm thành công.';
	END
END

EXEC sp_NhapDiem 'HS11', 'M01', 'I2023', 8.0, 7.5, 8.0, 9.0 -- Thử Procedure 2.1

-- 2.2: Tạo proc cho sửa điểm
CREATE PROC sp_SuaDiem @MaHS char(10),@MaMon char(10), @MaHocKy char(10), @DiemMieng float, @Diem15p float, @Diem1tiet float, @DiemThi float
AS
BEGIN
	IF (NOT EXISTS (SELECT * FROM DIEM WHERE MaHS = @MaHS AND MaMon = @MaMon AND MaHocKy = @MaHocKy))
		PRINT N'Thông tin điểm của học sinh này không tồn tại trong hệ thống.'
	ELSE
	BEGIN
		UPDATE DIEM 
		SET 
			DiemMieng = @DiemMieng, 
			Diem15p = @Diem15p, 
			Diem1tiet = @Diem1tiet, 
			DiemThi = @DiemThi 
		WHERE 
			MaHS = @MaHS AND 
			MaMon = @MaMon AND 
			MaHocKy = @MaHocKy;
		PRINT N'Sửa điểm thành công.';
	END
END

EXEC sp_SuaDiem 'HS11', 'M01', 'II2023', 8.0, 7.5, 8.0, 9.0


-- 2.3: Tạo proc cho xoá điểm
CREATE PROC sp_XoaDiem @MaHS char(10),@MaMon char(10), @MaHocKy char(10)
AS
BEGIN
	IF (NOT EXISTS (SELECT * FROM DIEM WHERE MaHS = @MaHS AND MaMon = @MaMon AND MaHocKy = @MaHocKy))
		PRINT N'Thông tin điểm của học sinh này không tồn tại trong hệ thống.'
	ELSE
	BEGIN
		DELETE FROM DIEM WHERE MaHS = @MaHS AND MaMon = @MaMon AND MaHocKy = @MaHocKy;
		PRINT N'Xoá điểm thành công.';
	END
END

EXEC sp_XoaDiem 'HS11', 'M01', 'II2023' -- Thử thủ túc xóa điểm học sinh



---- Phần 4 và 5: Báo cáo kết quả học tập ----

-- 4.1: Tạo proc cho in báo cáo học lực theo lớp
CREATE PROC sp_BaoCaoHocLucTheoLop
    @MaLop CHAR(10)
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM LOP WHERE MaLop = @MaLop)
		PRINT N'Không tồn tại mã lớp này trong hệ thống'
	ELSE
		SELECT HOCSINH.MaHS, v_KETQUA.TenHS, LOP.TenLop, v_KETQUA.TenHocKy, v_KETQUA.DiemTB, v_KETQUA.XepLoai
		FROM LOP, HOCSINH, v_KETQUA
		WHERE HOCSINH.MaHS = v_KETQUA.MaHS
			AND HOCSINH.MaLop = @MaLop
			AND LOP.MaLop = HOCSINH.MaLop
		ORDER BY v_KETQUA.TenHS
END	
GO

EXEC sp_BaoCaoHocLucTheoLop 'L01'; -- Nhập điểm cho học sinh lớp 10A nên sẽ chỉ hiện danh sách lớp 10A

-- 4.2: Tạo proc cho in báo cáo thống kê học lực
CREATE OR ALTER PROCEDURE sp_ThongKeHocLuc
    @MaLop CHAR(10) = NULL,       -- Mặc định NULL
    @NamHoc NVARCHAR(20) = NULL   -- Mặc định NULL
AS
BEGIN
    SELECT 
        XepLoai,
        COUNT(*) AS SoLuong,
        CAST(
            100.0 * COUNT(*) / 
            (SELECT COUNT(*)
             FROM v_KETQUA, HOCKY, HOCSINH
             WHERE v_KETQUA.MaHS = HOCSINH.MaHS
               AND v_KETQUA.TenHocKy = HOCKY.TenHocKy
               AND (@MaLop IS NULL OR HOCSINH.MaLop = @MaLop)
               AND (@NamHoc IS NULL OR HOCKY.NamHoc = @NamHoc)
            )
        AS DECIMAL(5,2)) AS TyLePhanTram
    FROM v_KETQUA, HOCKY, HOCSINH
    WHERE v_KETQUA.MaHS = HOCSINH.MaHS
      AND v_KETQUA.TenHocKy = HOCKY.TenHocKy
      AND (@MaLop IS NULL OR HOCSINH.MaLop = @MaLop)
      AND (@NamHoc IS NULL OR HOCKY.NamHoc = @NamHoc)
    GROUP BY XepLoai
    ORDER BY 
        CASE 
            WHEN XepLoai = N'Giỏi' THEN 1
            WHEN XepLoai = N'Khá' THEN 2
            WHEN XepLoai = N'Trung bình' THEN 3
            WHEN XepLoai = N'Yếu' THEN 4
            ELSE 5
        END
END
GO

EXEC sp_ThongKeHocLuc 'L01',NULL


-- 5.1: Tạo view cho báo cáo học lực chi tiết tổng hợp
CREATE VIEW v_BaoCaoTongHop AS
SELECT DISTINCT
    v_KETQUA.MaHS,
    v_KETQUA.TenHS,
    LOP.TenLop,
    v_KETQUA.TenHocKy,
    v_KETQUA.DiemTB,
    v_KETQUA.XepLoai,
    v_HANHKIEM.HanhKiem
FROM HOCSINH, LOP, v_KETQUA, HOCKY, v_HANHKIEM
WHERE 
    HOCSINH.MaLop = LOP.MaLop
    AND HOCSINH.MaHS = v_KETQUA.MaHS
    AND HOCSINH.MaHS = v_HANHKIEM.MaHS
GO

SELECT * FROM v_BaoCaoTongHop


-- 5.2: Tạo view cho thống kê xếp loại theo lớp
CREATE VIEW v_ThongKeXepLoaiTheoLop AS
SELECT 
    LOP.TenLop,
    v_KETQUA.TenHocKy,
    v_KETQUA.XepLoai,
    COUNT(*) AS SoLuong
FROM HOCSINH, v_KETQUA, LOP
WHERE 
    HOCSINH.MaHS = v_KETQUA.MaHS AND
    HOCSINH.MaLop = LOP.MaLop
GROUP BY 
    LOP.TenLop, 
    v_KETQUA.TenHocKy,
    v_KETQUA.XepLoai;
GO

SELECT * FROM v_ThongKeXepLoaiTheoLop



---- Phần 6: Quản lý học bổng ----
CREATE PROCEDURE sp_XetHocBong
    @MaHocKy CHAR(10)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM HOCKY WHERE HOCKY.MaHocKy = @MaHocKy)
    BEGIN
        PRINT N'Mã học kỳ [' + @MaHocKy + N'] không tồn tại.';
        RETURN;
    END

    IF OBJECT_ID('tempdb..#TempHocBong') IS NOT NULL
        DROP TABLE #TempHocBong;

    CREATE TABLE #TempHocBong (
        MaHS CHAR(10), MaHocBong CHAR(10), MaHocKy CHAR(10),
        NgayNhan DATE, TrangThai NVARCHAR(50)
    );

    INSERT INTO #TempHocBong (MaHS, MaHocBong, MaHocKy, NgayNhan, TrangThai)
    SELECT v_KETQUA.MaHS, 'HB001', v_KETQUA.MaHocKy, GETDATE(), N'Đủ điều kiện'
    FROM v_KETQUA, v_HANHKIEM
    WHERE v_KETQUA.MaHS = v_HANHKIEM.MaHS
      AND v_KETQUA.MaHocKy = v_HANHKIEM.MaHocKy
      AND v_KETQUA.MaHocKy = @MaHocKy
      AND v_KETQUA.DiemTB >= 8.5
      AND v_HANHKIEM.HanhKiem = N'Tốt';

    INSERT INTO #TempHocBong (MaHS, MaHocBong, MaHocKy, NgayNhan, TrangThai)
    SELECT v_KETQUA.MaHS, 'HB003', v_KETQUA.MaHocKy, GETDATE(), N'Đủ điều kiện'
    FROM v_KETQUA, v_HANHKIEM
    WHERE v_KETQUA.MaHS = v_HANHKIEM.MaHS
      AND v_KETQUA.MaHocKy = v_HANHKIEM.MaHocKy
      AND v_KETQUA.MaHocKy = @MaHocKy
      AND v_KETQUA.DiemTB >= 8.0 AND v_KETQUA.DiemTB < 8.5
      AND v_HANHKIEM.HanhKiem IN (N'Tốt', N'Khá')
      AND NOT EXISTS (
            SELECT 1 FROM #TempHocBong
            WHERE #TempHocBong.MaHS = v_KETQUA.MaHS AND #TempHocBong.MaHocKy = v_KETQUA.MaHocKy
      );

    INSERT INTO #TempHocBong (MaHS, MaHocBong, MaHocKy, NgayNhan, TrangThai)
    SELECT v_KETQUA.MaHS, HOCBONG.MaHocBong, v_KETQUA.MaHocKy, GETDATE(), N'Đủ điều kiện'
    FROM v_KETQUA, HOCBONG, v_HANHKIEM
    WHERE v_KETQUA.MaHS = v_HANHKIEM.MaHS
      AND v_KETQUA.MaHocKy = v_HANHKIEM.MaHocKy
      AND HOCBONG.MaHocBong = 'HB004'
      AND v_KETQUA.MaHocKy = @MaHocKy
      AND v_KETQUA.DiemTB >= 9.0
      AND v_HANHKIEM.HanhKiem = N'Tốt'
      AND HOCBONG.DieuKien LIKE N'%DTB >= 9.0%'
      AND NOT EXISTS (
            SELECT 1 FROM #TempHocBong
            WHERE #TempHocBong.MaHS = v_KETQUA.MaHS AND #TempHocBong.MaHocKy = v_KETQUA.MaHocKy
      );

    SELECT
        HOCSINH.MaHS, HOCSINH.TenHS, LOP.TenLop, HOCKY.TenHocKy, HOCKY.NamHoc,
        HOCBONG.TenHocBong, HOCBONG.GiaTri, #TempHocBong.NgayNhan, #TempHocBong.TrangThai
    FROM #TempHocBong, HOCSINH, LOP, HOCKY, HOCBONG
    WHERE #TempHocBong.MaHS = HOCSINH.MaHS
      AND HOCSINH.MaLop = LOP.MaLop
      AND #TempHocBong.MaHocKy = HOCKY.MaHocKy
      AND #TempHocBong.MaHocBong = HOCBONG.MaHocBong
    ORDER BY LOP.TenLop, HOCSINH.TenHS, HOCBONG.GiaTri DESC;

    DROP TABLE #TempHocBong;
END
GO


EXEC sp_XetHocBong 'HK01';