create database ThuVienDHXD_132364
go
use ThuVienDHXD_132364
 go
 create table SinhVien(
	MaSV int primary key identity(1,1),
	Ho NVarChar(25) NOT NULL,
	TenDem NVarChar(25) NOT NULL,
	Ten NVarChar(25) NOT NULL,
	NgaySinh DateTime NOT NULL,
	GioiTinh bit NULL
 );
 go
 create table DauSach(
	MaDS int primary key identity(1,1),
	TenDS NVarChar(200) NOT NULL,
	TrangTRhai bit default(0) NOT NULL
 );
 go
create table CuonSach(
	MACS int primary key identity(1,1),
	MADS Int NOT NULL,
	TinhTrang bit default(0) NOT NULL
	foreign key (MaDS) references DauSach(MaDS)
 );
 go
create table DangKy(
	MaDK int primary key identity(1,1),
	MaSV int not null,
	MaDS int not null,
	NgayDK datetime not null default getdate(),
	SoDT nvarchar(20) not null,
	GhiChu nvarchar(200),
	foreign key (MaSV) references SinhVien(MaSV),
	foreign key (MaDS) references DauSach(MaDS)
 );
 go
create table Muon (
	MaDK int not null,
	MaCS int not null,
	NgayMuon datetime not null default getdate(),
	NgayHetHan AS NgayMuon + 14
);
go
create table QuaTrinhMuon (
	MaDK int not null,
	MaCS int not null,
	NgayMuon datetime not null,
	NgayHetHan datetime not null,
	NgayTra datetime not null default getdate(),
	SoTienPhat float,
	foreign key (MaDK) references DangKy(MaDK),
	foreign key (MaCS) references CuonSach(MaCS)
);

 --1.1 moi bang it nhat 5 dong du lieu
 use ThuVienDHXD_208764
 select * from DauSach
 go
INSERT INTO SinhVien(Ho, TenDem, Ten, NgaySinh, GioiTinh)
VALUES(N'Đoàn',N'Đình',N'Mạnh','2002-11-01',0),
	(N'TRần',N'Đình',N'Sơn','2001-01-01',0),
	(N'Bùi',N'Minh',N'Phượng','2003-04-20',1),
	(N'Hoàng',N'Hà',N'Nhi','2000-02-23',1),
	(N'Trần',N'Thị',N'Linh','2000-01-19',1);
INSERT INTO DauSach(TenDS, TrangTRhai)
VALUES(N'Trí tuệ nhân tạo',1 ),
	(N'Lập trình nâng cao',1 ),
	(N'Cơ sở dữ liệu',0 ),
	(N'Xử lý ảnh',0 ),
	(N'Lập trình C++',1 );

INSERT INTO CuonSach(MaDS, TinhTrang)
VALUES(3,1 ),
	(3,3),
	(3,4 ),
	(3,5 ),
	(3,1 );
INSERT INTO DangKy(MaSV, MaDS, NgayDK, SoDT, GhiChu)
VALUES(3,2,'2021-03-01','0363708648','no comment'),
(5,3,'2022-04-01','0363708648','no comment'),
(1,5,'2022-04-01','0363708648','no comment'),
(11,1,'2022-04-01','0363708648','no comment'),
(1,2,'2022-03-01','0363708648','no comment');

INSERT INTO Muon(MaDK, MaCS, NgayHetHan)
VALUES(1,2,'2022-04-01'),
(3,3,'2022-04-01'),
(4,5,'2022-04-01'),
(2,1,'2022-04-01'),
(5,4,'2022-03-30');

insert into QuaTrinhMuon(MaDK, MaCS, NgayMuon, NgayHetHan,SoTienPhat)
values (1 ,2, '2021-12-20', '2022-05-01', 10.000),
	 (2, 3,'2021-10-10', '2021-05-01', 11.000),
	 (3, 2,'2022-05-11', '2022-05-01', 12.000),
	 (3, 4,'2022-04-03', '2022-05-01', 13.000),
	 (1, 5,'2022-06-29', '2022-05-01', 14.000);
--1.2 
--1
select TenDS,TrangTRhai=CASE WHEN TrangTRhai=1 THEN N'Còn' ELSE N'Không' END
from DauSach

--3
SELECT TenDS, COUNT(CuonSach.MaDS) 
FROM DauSach 
JOIN CuonSach ON CuonSach.MaDS = DauSach.MaDS
WHERE CuonSach.TinhTrang = 0
GROUP BY TenDS
--4
SELECT * FROM SinhVien 
WHERE MaSV NOT IN (SELECT MaSV FROM dbo.DangKy JOIN Muon ON Muon.MaDK = DangKy.MaDK)

--5
SELECT CONCAT_WS(' ', Ho, TenDem, Ten) AS HoTen, NgayHetHan, NgayTra FROM dbo.SinhVien JOIN dbo.DangKy ON DangKy.MaSV = SinhVien.MaSV JOIN dbo.QuaTrinhMuon ON QuaTrinhMuon.MaDK = DangKy.MaDK
WHERE NgayHetHan > NgayTra

--6
SELECT TenDS, CuonSach.MaCS FROM dbo.DauSach JOIN dbo.CuonSach ON CuonSach.MaDS = DauSach.MaDS JOIN dbo.QuaTrinhMuon ON QuaTrinhMuon.MaCS = CuonSach.MaCS
WHERE DATEDIFF(DAY,GETDATE(),NgayTra) = 0

-- 7 
if OBJECT_ID('tg_themMuon') is not null
drop trigger tg_themMuon
GO
create trigger tg_themMuon
on Muon for insert
as
begin
	declare @MaCS int
	select @MaCS = inserted.MaCS from inserted

	IF NOT EXISTS(SELECT MaCS FROM CuonSach WHERE MaCS = @MaCS)
	BEGIN
		RAISERROR('MaCS khong ton tai',12,1)
		ROLLBACK
	END

	update CuonSach
	set TinhTrang = 1
	where MaCS = @MaCS
end
-- test
SELECT * FROM Muon
SELECT * FROM CuonSach
insert into Muon(MaDK, MaCS, NgayMuon)
values (1 ,2, 14)

--8
GO	
CREATE PROC sp_muonsach
	@madangky INT
AS
BEGIN	
	DECLARE @socuonsachmuon INT
	DECLARE @socuonsachconlai INT
	DECLARE @macs INT 
	SELECT @socuonsachmuon = COUNT(MaDK) FROM dbo.DangKy GROUP BY MaSV
	SELECT @macs = MaCS, @socuonsachconlai = COUNT(CuonSach.MaDS) FROM dbo.CuonSach JOIN dbo.DangKy ON DangKy.MaDS = CuonSach.MaDS WHERE TinhTrang = 0 AND MaDK = @madangky GROUP BY MaCS
	IF @socuonsachmuon > 5
		BEGIN
			RAISERROR('Qua so luong sach duoc muon',12,1)
			ROLLBACK
		END
	ELSE
    IF @socuonsachconlai = 0 
		BEGIN
			RAISERROR('Khong du so luong sach',12,1)
			ROLLBACK
		END
	ELSE
		INSERT dbo.Muon
		(
		    MaDK,
		    MaCS,
		    NgayMuon
		)
		VALUES
		(   @madangky,      -- MaDK - int
		    @macs,      -- MaCS - int
		    DEFAULT -- NgayMuon - datetime
		)
END
GO

-- 9
GO
create proc sp_trasach
	@MaDK int
as
begin
	insert into QuaTrinhMuon(MaDK, MaCS, NgayMuon, NgayHetHan, NgayTra, SoTienPhat)
	SELECT DangKy.MaDK, Muon.MaCS, Muon.NgayMuon, Muon.NgayHetHan, QuaTrinhMuon.NgayTra , 1500*DATEDIFF(day, QuaTrinhMuon.NgayTra, Muon.NgayHetHan) 
	FROM DangKy JOIN Muon ON Muon.MaDK = DangKy.MaDK JOIN QuaTrinhMuon ON QuaTrinhMuon.MaDK = DangKy.MaDK
	WHERE DangKy.MaDK = @MaDK
	DELETE FROM Muon WHERE Muon.MaDK = @MaDK
end