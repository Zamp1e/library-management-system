-- ============================================
-- 图书馆图书管理系统 - 数据库初始化脚本 (v2)
-- ============================================

CREATE DATABASE IF NOT EXISTS library DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE library;

-- ============================================
-- 删除已有表 (按依赖顺序)
-- ============================================
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS operation_logs;
DROP TABLE IF EXISTS borrows;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS borrow_config;
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================
-- 1. 用户表
-- ============================================
CREATE TABLE users (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    username    VARCHAR(50)   NOT NULL COMMENT '登录用户名',
    password    VARCHAR(255)  NOT NULL COMMENT '密码(Bcrypt加密)',
    role        VARCHAR(20)   NOT NULL DEFAULT 'reader' COMMENT '角色: super_admin | admin | reader',
    name        VARCHAR(50)   NOT NULL COMMENT '真实姓名',
    gender      CHAR(1)       DEFAULT 'U' COMMENT '性别: M=男 F=女 U=未知',
    phone       VARCHAR(20)   DEFAULT '' COMMENT '手机号',
    email       VARCHAR(100)  DEFAULT '' COMMENT '邮箱',
    avatar      VARCHAR(300)  DEFAULT '' COMMENT '头像URL',
    max_borrow  INT           NOT NULL DEFAULT 5 COMMENT '最大同时借阅数量',
    status      TINYINT       NOT NULL DEFAULT 1 COMMENT '账号状态: 1=正常 0=禁用',
    created_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
    updated_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',

    CONSTRAINT chk_users_role    CHECK (role IN ('super_admin', 'admin', 'reader')),
    CONSTRAINT chk_users_gender  CHECK (gender IN ('M', 'F', 'U')),
    CONSTRAINT chk_users_status  CHECK (status IN (0, 1)),
    CONSTRAINT chk_users_borrow  CHECK (max_borrow BETWEEN 1 AND 20),

    UNIQUE  KEY uk_username (username),
    INDEX   idx_users_role (role),
    INDEX   idx_users_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- ============================================
-- 2. 图书表
-- ============================================
CREATE TABLE books (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    isbn         VARCHAR(30)    NOT NULL COMMENT 'ISBN编号',
    title        VARCHAR(200)   NOT NULL COMMENT '书名',
    author       VARCHAR(100)   NOT NULL COMMENT '作者',
    publisher    VARCHAR(100)   NOT NULL COMMENT '出版社',
    publish_date DATE           DEFAULT NULL COMMENT '出版日期',
    edition      VARCHAR(30)    DEFAULT '' COMMENT '版次',
    lang         VARCHAR(20)    DEFAULT '中文' COMMENT '语种',
    pages        INT            DEFAULT 0 COMMENT '页数',
    category     VARCHAR(50)    NOT NULL COMMENT '分类',
    price        DECIMAL(10,2)  NOT NULL COMMENT '定价',
    total        INT            NOT NULL DEFAULT 1 COMMENT '馆藏总数',
    available    INT            NOT NULL DEFAULT 1 COMMENT '当前可借数量',
    shelf_code   VARCHAR(30)    DEFAULT '' COMMENT '书架编号',
    location     VARCHAR(100)   DEFAULT '' COMMENT '馆藏位置描述',
    cover        VARCHAR(500)   DEFAULT '' COMMENT '封面图片URL',
    description  TEXT           COMMENT '图书简介',
    status       TINYINT        NOT NULL DEFAULT 1 COMMENT '图书状态: 1=在馆 0=下架',
    created_at   DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '入库时间',
    updated_at   DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',

    CONSTRAINT chk_books_total     CHECK (total >= 0),
    CONSTRAINT chk_books_available CHECK (available >= 0 AND available <= total),
    CONSTRAINT chk_books_price     CHECK (price >= 0),
    CONSTRAINT chk_books_pages     CHECK (pages >= 0),
    CONSTRAINT chk_books_status    CHECK (status IN (0, 1)),

    UNIQUE  KEY uk_isbn (isbn),
    INDEX   idx_books_category (category),
    INDEX   idx_books_title (title),
    INDEX   idx_books_author (author),
    INDEX   idx_books_publisher (publisher),
    FULLTEXT idx_books_search (title, author, description)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='图书表';

-- ============================================
-- 3. 借阅记录表
-- ============================================
CREATE TABLE borrows (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    book_id     INT            NOT NULL COMMENT '图书ID',
    user_id     INT            NOT NULL COMMENT '借阅用户ID',
    book_title  VARCHAR(200)   NOT NULL COMMENT '图书名称(冗余，防书名变更)',
    book_isbn   VARCHAR(30)    NOT NULL COMMENT 'ISBN(冗余)',
    user_name   VARCHAR(50)    NOT NULL COMMENT '借阅人姓名(冗余)',
    status      VARCHAR(20)    NOT NULL DEFAULT 'applying' COMMENT 'applying=审核中 | borrowed=借阅中 | returned=已归还 | rejected=已拒绝 | overdue=逾期',
    borrow_date DATE           NOT NULL COMMENT '借阅/申请日期',
    due_date    DATE           NOT NULL COMMENT '应还日期',
    return_date DATE           DEFAULT NULL COMMENT '实际归还日期',
    renew_count TINYINT        NOT NULL DEFAULT 0 COMMENT '续借次数',
    fine        DECIMAL(10,2)  NOT NULL DEFAULT 0.00 COMMENT '逾期罚款金额',
    fine_paid   TINYINT        NOT NULL DEFAULT 0 COMMENT '罚款是否缴纳: 1=已缴 0=未缴',
    note        VARCHAR(500)   DEFAULT '' COMMENT '备注',
    created_at  DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at  DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',

    CONSTRAINT chk_borrows_status     CHECK (status IN ('applying', 'borrowed', 'returned', 'rejected', 'overdue')),
    CONSTRAINT chk_borrows_fine       CHECK (fine >= 0),
    CONSTRAINT chk_borrows_renew      CHECK (renew_count >= 0),

    CONSTRAINT fk_borrows_book FOREIGN KEY (book_id) REFERENCES books(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_borrows_user FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    INDEX idx_borrows_status (status),
    INDEX idx_borrows_user (user_id),
    INDEX idx_borrows_book (book_id),
    INDEX idx_borrows_due (due_date),
    INDEX idx_borrows_date (borrow_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='借阅记录表';

-- ============================================
-- 4. 操作日志表
-- ============================================
CREATE TABLE operation_logs (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id      INT           NOT NULL COMMENT '操作人ID',
    username     VARCHAR(50)   NOT NULL COMMENT '操作人用户名',
    role         VARCHAR(20)   NOT NULL COMMENT '操作人角色',
    action       VARCHAR(50)   NOT NULL COMMENT '操作类型: LOGIN | ADD_BOOK | EDIT_BOOK | DEL_BOOK | BORROW | RETURN | APPROVE | REJECT | ADD_USER | EDIT_USER | DEL_USER | TOGGLE_USER',
    target_type  VARCHAR(30)   DEFAULT '' COMMENT '操作对象类型: book | borrow | user',
    target_id    INT           DEFAULT NULL COMMENT '操作对象ID',
    detail       VARCHAR(500)  DEFAULT '' COMMENT '操作详情',
    ip           VARCHAR(45)   DEFAULT '' COMMENT '操作IP地址',
    created_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',

    CONSTRAINT fk_log_user FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE ON UPDATE CASCADE,

    INDEX idx_log_user (user_id),
    INDEX idx_log_action (action),
    INDEX idx_log_time (created_at),
    INDEX idx_log_target (target_type, target_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='操作日志表';

-- ============================================
-- 5. 借阅配置表
-- ============================================
CREATE TABLE borrow_config (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    max_borrow_days INT           NOT NULL DEFAULT 30 COMMENT '最大借阅天数',
    max_renew_times TINYINT       NOT NULL DEFAULT 1 COMMENT '最大续借次数',
    renew_days      INT           NOT NULL DEFAULT 15 COMMENT '续借天数',
    fine_per_day    DECIMAL(10,2) NOT NULL DEFAULT 0.50 COMMENT '逾期罚款(元/天)',
    updated_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',

    CONSTRAINT chk_config_days  CHECK (max_borrow_days > 0),
    CONSTRAINT chk_config_fine  CHECK (fine_per_day >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='借阅配置表';

-- ============================================
-- 初始数据
-- ============================================

-- 借阅默认配置
INSERT INTO borrow_config (max_borrow_days, max_renew_times, renew_days, fine_per_day) VALUES
(30, 1, 15, 0.50);

-- 用户
INSERT INTO users (username, password, role, name, gender, phone, email, max_borrow, created_at) VALUES
('admin',     'admin123', 'super_admin', '系统管理员', 'M', '13800000001', 'admin@lib.com',    10, '2026-06-08 09:00:00'),
('librarian', 'lib123',   'admin',       '图书管理员', 'F', '13800000002', 'librarian@lib.com', 8, '2026-06-08 09:00:00'),
('zhangsan',  '123456',   'reader',      '张三',       'M', '13800000003', 'zhangsan@qq.com',   5, '2026-06-08 10:00:00'),
('lisi',      '123456',   'reader',      '李四',       'F', '13800000004', 'lisi@qq.com',       5, '2026-06-08 10:30:00');

-- 图书
INSERT INTO books (isbn, title, author, publisher, publish_date, edition, lang, pages, category, price, total, available, shelf_code, location, description, created_at) VALUES
('978-7-111-59058-1', 'Java核心技术 卷I',        '霍斯特曼',         '机械工业出版社', '2020-07-01', '第11版', '中文', 752, '计算机', 149.00, 5, 3, 'A-03-15', 'A区-3排-15号', '本书是Java领域最有影响力和价值的著作之一，由拥有20多年教学与研究经验的资深Java技术专家撰写，全面覆盖Java SE 9/10/11的新特性。', '2026-01-10 08:30:00'),
('978-7-121-38338-5', 'Spring Boot实战',         '克雷格·沃尔斯',   '人民邮电出版社', '2021-03-01', '第6版', '中文', 468, '计算机',  99.00, 3, 2, 'A-03-16', 'A区-3排-16号', '本书全面讲解Spring Boot 2.x的实际应用，从入门到进阶，循序渐进地介绍Spring Boot的各个核心特性，包括自动配置、起步依赖、Actuator等。', '2026-02-15 10:00:00'),
('978-7-302-47595-8', '数据结构与算法分析',      '马克·艾伦·维斯', '清华大学出版社', '2019-08-01', '第3版', '中文', 628, '计算机',  79.00, 4, 4, 'B-01-05', 'B区-1排-5号',  '本书是数据结构和算法分析的经典教材，使用Java语言描述，详细讨论了数据结构和算法分析，包含大量示例和习题。', '2026-03-01 14:00:00'),
('978-7-111-68482-3', '深入理解Java虚拟机',      '周志明',           '机械工业出版社', '2022-06-01', '第3版', '中文', 560, '计算机', 129.00, 3, 1, 'A-03-17', 'A区-3排-17号', '本书全面系统地介绍了Java虚拟机的工作原理，包括内存管理、类加载机制、垃圾收集器、性能调优等核心内容。', '2026-04-01 09:00:00'),
('978-7-121-41312-2', 'MySQL必知必会',           'Ben Forta',        '人民邮电出版社', '2021-01-01', '第1版', '中文', 320, '数据库',  59.00, 6, 5, 'B-02-10', 'B区-2排-10号', '本书是MySQL领域的经典入门书籍，通过大量实例帮助读者快速掌握SQL查询技巧和数据库操作，适合初学者快速上手。', '2026-04-15 11:00:00'),
('978-7-115-54478-1', '图解HTTP',                '上野宣',           '人民邮电出版社', '2020-03-01', '第1版', '中文', 304, '网络',    49.00, 3, 0, 'C-01-03', 'C区-1排-3号',  '本书用大量生动形象的漫画和插图，深入浅出地讲解了HTTP协议的工作原理、报文结构、状态码等核心知识。', '2026-05-01 15:00:00'),
('978-7-111-69142-5', '设计模式之美',            '王争',             '机械工业出版社', '2022-01-01', '第1版', '中文', 488, '计算机', 119.00, 2, 2, 'A-02-08', 'A区-2排-8号',  '本书结合作者多年的实践经验，用通俗易懂的语言讲解了23种经典设计模式以及它们在真实项目中的应用。', '2026-05-10 09:30:00'),
('978-7-121-38339-1', 'JavaScript高级程序设计',  'Matt Frisbie',     '人民邮电出版社', '2021-09-01', '第4版', '中文', 896, '计算机', 139.00, 4, 3, 'A-01-12', 'A区-1排-12号', '本书是JavaScript"红宝书"，全面深入地讲解了JavaScript的核心概念、DOM、BOM、事件、Ajax等所有重要知识点。', '2026-06-01 08:00:00');

-- 借阅记录
INSERT INTO borrows (book_id, user_id, book_title, book_isbn, user_name, status, borrow_date, due_date, return_date, renew_count, fine, fine_paid) VALUES
(1, 3, 'Java核心技术 卷I',        '978-7-111-59058-1', '张三', 'borrowed', '2026-05-20', '2026-06-19', NULL,   0, 0.00, 0),
(2, 3, 'Spring Boot实战',         '978-7-121-38338-5', '张三', 'returned', '2026-05-01', '2026-05-31', '2026-05-28', 0, 0.00, 0),
(4, 4, '深入理解Java虚拟机',      '978-7-111-68482-3', '李四', 'borrowed', '2026-06-01', '2026-07-01', NULL,   0, 0.00, 0),
(5, 4, 'MySQL必知必会',           '978-7-121-41312-2', '李四', 'returned', '2026-04-10', '2026-05-10', '2026-05-05', 0, 0.00, 0),
(6, 4, '图解HTTP',                '978-7-115-54478-1', '李四', 'borrowed', '2026-06-05', '2026-07-05', NULL,   0, 0.00, 0),
(3, 3, '数据结构与算法分析',      '978-7-302-47595-8', '张三', 'applying', '2026-06-09', '2026-07-09', NULL,   0, 0.00, 0);

-- 操作日志初始数据
INSERT INTO operation_logs (user_id, username, role, action, target_type, target_id, detail) VALUES
(1, 'admin',     'super_admin', 'LOGIN',      '',      NULL, '系统管理员登录后台'),
(2, 'librarian', 'admin',       'ADD_BOOK',   'book',  8,    '新增图书《JavaScript高级程序设计》'),
(2, 'librarian', 'admin',       'APPROVE',    'borrow', 1,    '审批通过张三借阅《Java核心技术 卷I》'),
(2, 'librarian', 'admin',       'APPROVE',    'borrow', 3,    '审批通过李四借阅《深入理解Java虚拟机》');

-- ============================================
-- 触发器
-- ============================================

DELIMITER //

CREATE TRIGGER trg_borrow_insert
AFTER INSERT ON borrows
FOR EACH ROW
BEGIN
    IF NEW.status = 'borrowed' THEN
        UPDATE books SET available = available - 1 WHERE id = NEW.book_id;
    END IF;
END //

CREATE TRIGGER trg_borrow_update
AFTER UPDATE ON borrows
FOR EACH ROW
BEGIN
    IF OLD.status = 'applying' AND NEW.status = 'borrowed' THEN
        UPDATE books SET available = available - 1 WHERE id = NEW.book_id;
    END IF;
    IF OLD.status = 'borrowed' AND NEW.status = 'returned' THEN
        UPDATE books SET available = available + 1 WHERE id = NEW.book_id;
        IF NEW.return_date > NEW.due_date THEN
            SET @days = DATEDIFF(NEW.return_date, NEW.due_date);
            SET @rate = (SELECT fine_per_day FROM borrow_config LIMIT 1);
            UPDATE borrows SET fine = @days * @rate, status = 'returned'
            WHERE id = NEW.id;
        END IF;
    END IF;
END //

DELIMITER ;
