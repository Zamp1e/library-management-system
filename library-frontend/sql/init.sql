-- ============================================
-- 图书馆图书管理系统 - 数据库初始化脚本
-- ============================================

CREATE DATABASE IF NOT EXISTS library DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE library;

-- ============================================
-- 用户表
-- ============================================
DROP TABLE IF EXISTS borrows;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    username    VARCHAR(50)  NOT NULL UNIQUE COMMENT '用户名',
    password    VARCHAR(255) NOT NULL COMMENT '密码',
    role        VARCHAR(20)  NOT NULL DEFAULT 'reader' COMMENT '角色: super_admin/admin/reader',
    name        VARCHAR(50)  NOT NULL COMMENT '真实姓名',
    phone       VARCHAR(20)  DEFAULT '' COMMENT '手机号',
    email       VARCHAR(100) DEFAULT '' COMMENT '邮箱',
    status      TINYINT      NOT NULL DEFAULT 1 COMMENT '1=正常 0=禁用',
    created_at  DATE         NOT NULL COMMENT '创建日期',
    INDEX idx_users_role (role),
    INDEX idx_users_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- ============================================
-- 图书表
-- ============================================
CREATE TABLE books (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    isbn        VARCHAR(30)  NOT NULL COMMENT 'ISBN编号',
    title       VARCHAR(200) NOT NULL COMMENT '书名',
    author      VARCHAR(100) NOT NULL COMMENT '作者',
    publisher   VARCHAR(100) NOT NULL COMMENT '出版社',
    category    VARCHAR(50)  NOT NULL COMMENT '分类',
    price       DECIMAL(10,2) NOT NULL COMMENT '价格',
    total       INT          NOT NULL DEFAULT 1 COMMENT '馆藏总数',
    available   INT          NOT NULL DEFAULT 1 COMMENT '可借数量',
    cover       VARCHAR(500) DEFAULT '' COMMENT '封面图片URL',
    description TEXT         COMMENT '图书简介',
    location    VARCHAR(100) DEFAULT '' COMMENT '馆藏位置',
    created_at  DATE         NOT NULL COMMENT '入库日期',
    INDEX idx_books_category (category),
    INDEX idx_books_title (title),
    INDEX idx_books_author (author)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='图书表';

-- ============================================
-- 借阅记录表
-- ============================================
CREATE TABLE borrows (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    book_id     INT          NOT NULL COMMENT '图书ID',
    user_id     INT          NOT NULL COMMENT '借阅用户ID',
    book_title  VARCHAR(200) NOT NULL COMMENT '图书名称(冗余)',
    user_name   VARCHAR(50)  NOT NULL COMMENT '借阅人姓名(冗余)',
    status      VARCHAR(20)  NOT NULL DEFAULT 'applying' COMMENT 'applying=审核中 borrowed=借阅中 returned=已归还 rejected=已拒绝',
    borrow_date DATE         NOT NULL COMMENT '借阅日期',
    due_date    DATE         NOT NULL COMMENT '应还日期',
    return_date DATE         DEFAULT NULL COMMENT '实际归还日期',
    FOREIGN KEY (book_id) REFERENCES books(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_borrows_status (status),
    INDEX idx_borrows_user (user_id),
    INDEX idx_borrows_book (book_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='借阅记录表';

-- ============================================
-- 初始数据
-- ============================================

-- 用户 (密码明文，后续用Spring Security BCrypt加密)
INSERT INTO users (username, password, role, name, created_at) VALUES
('admin',     'admin123', 'super_admin', '系统管理员',   '2026-06-08'),
('librarian', 'lib123',   'admin',       '图书管理员',   '2026-06-08'),
('zhangsan',  '123456',   'reader',      '张三',         '2026-06-08'),
('lisi',      '123456',   'reader',      '李四',         '2026-06-08');

-- 图书
INSERT INTO books (isbn, title, author, publisher, category, price, total, available, description, location, created_at) VALUES
('978-7-111-59058-1', 'Java核心技术 卷I',        '霍斯特曼',        '机械工业出版社', '计算机', 149.00, 5, 3, '本书是Java领域最有影响力和价值的著作之一，由拥有20多年教学与研究经验的资深Java技术专家撰写。',                                                        'A区-3排-15号', '2026-01-10'),
('978-7-121-38338-5', 'Spring Boot实战',         '克雷格·沃尔斯',  '人民邮电出版社', '计算机',  99.00, 3, 2, '本书全面讲解Spring Boot 2.x的实际应用，从入门到进阶，循序渐进地介绍Spring Boot的各个核心特性。',                                            'A区-3排-16号', '2026-02-15'),
('978-7-302-47595-8', '数据结构与算法分析',      '马克·艾伦·维斯', '清华大学出版社', '计算机',  79.00, 4, 4, '本书是数据结构和算法分析的经典教材，使用Java语言描述，详细讨论了数据结构和算法分析。',                                                      'B区-1排-5号',  '2026-03-01'),
('978-7-111-68482-3', '深入理解Java虚拟机',      '周志明',          '机械工业出版社', '计算机', 129.00, 3, 1, '本书全面系统地介绍了Java虚拟机的工作原理，包括内存管理、类加载机制、垃圾收集器等核心内容。',                                                'A区-3排-17号', '2026-04-01'),
('978-7-121-41312-2', 'MySQL必知必会',           'Ben Forta',       '人民邮电出版社', '数据库',  59.00, 6, 5, '本书是MySQL领域的经典入门书籍，通过大量实例帮助读者快速掌握SQL查询技巧和数据库操作。',                                                    'B区-2排-10号', '2026-04-15'),
('978-7-115-54478-1', '图解HTTP',                '上野宣',          '人民邮电出版社', '网络',    49.00, 3, 0, '本书用大量生动形象的漫画和插图，深入浅出地讲解了HTTP协议的工作原理、报文结构、状态码等核心知识。',                                        'C区-1排-3号',  '2026-05-01'),
('978-7-111-69142-5', '设计模式之美',            '王争',            '机械工业出版社', '计算机', 119.00, 2, 2, '本书结合作者多年的实践经验，用通俗易懂的语言讲解了23种经典设计模式以及它们在真实项目中的应用。',                                            'A区-2排-8号',  '2026-05-10'),
('978-7-121-38339-1', 'JavaScript高级程序设计',  'Matt Frisbie',    '人民邮电出版社', '计算机', 139.00, 4, 3, '本书是JavaScript"红宝书"，全面深入地讲解了JavaScript的核心概念、DOM、BOM、事件、Ajax等所有重要知识点。',                                  'A区-1排-12号', '2026-06-01');

-- 借阅记录
INSERT INTO borrows (book_id, user_id, book_title, user_name, status, borrow_date, due_date, return_date) VALUES
(1, 3, 'Java核心技术 卷I',        '张三', 'borrowed', '2026-05-20', '2026-06-20', NULL),
(2, 3, 'Spring Boot实战',         '张三', 'returned', '2026-05-01', '2026-06-01', '2026-05-28'),
(4, 4, '深入理解Java虚拟机',      '李四', 'borrowed', '2026-06-01', '2026-07-01', NULL),
(5, 4, 'MySQL必知必会',           '李四', 'returned', '2026-04-10', '2026-05-10', '2026-05-05'),
(6, 4, '图解HTTP',                '李四', 'borrowed', '2026-06-05', '2026-07-05', NULL),
(3, 3, '数据结构与算法分析',      '张三', 'applying', '2026-06-09', '2026-07-09', NULL);
