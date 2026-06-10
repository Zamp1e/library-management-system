# 图书管理系统 — 项目结构文档

## 快速导航

| 目标 | 关键文件 |
|------|---------|
| 看后端接口 | `backend/.../controller/` 5个Controller |
| 看数据库表 | `database/init.sql` 3张表+60条种子数据 |
| 看前端页面 | `frontend/admin/` 管理端6页 + `frontend/front/` 读者端5页 |
| 看API封装 | `frontend/js/api.js` 自动切换Mock/真实后端 |
| 看样式 | `frontend/css/style.css` CSS变量+动画系统 |

---

## 一、技术栈

| 层 | 技术 |
|----|------|
| 后端框架 | Spring Boot 3.2.0 |
| 语言 | Java 17 |
| 数据库 | MySQL 8.0 |
| ORM | Spring Data JPA (Hibernate) |
| 密码加密 | BCrypt (spring-security-crypto) |
| 构建 | Maven |
| 前端 | 原生 HTML5 + CSS3 + JavaScript（零框架） |
| 图表 | 手写 SVG |
| 版本控制 | Git |

---

## 二、项目树

```
课设程序/
├── backend/
│   ├── pom.xml                          # Maven依赖配置
│   └── src/main/
│       ├── resources/
│       │   ├── application.yml           # 数据库连接配置（不提交Git）
│       │   └── application.example.yml   # 配置模板
│       └── java/com/library/
│           ├── LibraryApplication.java   # Spring Boot 入口
│           ├── config/
│           │   ├── CorsConfig.java       # CORS跨域 + BCrypt Bean
│           │   ├── DataInitializer.java  # 启动时自动加密明文密码
│           │   └── GlobalExceptionHandler.java  # 全局异常处理
│           ├── controller/
│           │   ├── ApiResponse.java      # 统一响应格式 {code, data/message}
│           │   ├── AuthController.java   # POST /api/auth/login
│           │   ├── BookController.java   # CRUD /api/books
│           │   ├── BorrowController.java # /api/borrows 借阅管理
│           │   ├── StatsController.java  # GET /api/stats/overview 仪表盘
│           │   └── UserController.java   # CRUD /api/users
│           ├── entity/
│           │   ├── Book.java             # books 表实体
│           │   ├── Borrow.java           # borrows 表实体
│           │   └── User.java             # users 表实体
│           ├── repository/
│           │   ├── BookRepository.java   # 自定义搜索查询
│           │   ├── BorrowRepository.java # 逾期查询等
│           │   └── UserRepository.java   # 按角色/姓名查询
│           └── service/
│               ├── AuthService.java      # 登录验证+token生成
│               ├── BookService.java      # 图书CRUD+库存调节
│               ├── BorrowService.java    # 核心：借阅申请+审批+库存控制
│               └── UserService.java      # 用户CRUD
│
├── database/
│   └── init.sql                          # 建表+种子数据（4用户36书6借阅）
│
└── frontend/
    ├── css/
    │   └── style.css                     # 全局样式+CSS变量+动画系统
    ├── js/
    │   └── api.js                        # API封装层（Mock/真实自动切换）
    ├── mock/
    │   └── data.js                       # Mock种子数据+localStorage持久化
    ├── admin/                            # ====== 管理端 ======
    │   ├── common.js                     # 侧边栏+退出+动画+toast
    │   ├── login.html                    # 管理员登录
    │   ├── index.html                    # 仪表盘（统计卡+SVG图表）
    │   ├── books.html                    # 图书管理
    │   ├── borrows.html                  # 借阅管理（分组+筛选）
    │   ├── readers.html                  # 读者管理
    │   └── admins.html                   # 管理员账号管理
    └── front/                            # ====== 读者端 ======
        ├── common.js                     # 侧边栏+退出+动画+toast
        ├── login.html                    # 读者登录
        ├── register.html                 # 注册关闭提示
        ├── index.html                    # 图书检索+读者仪表盘
        ├── book-detail.html              # 图书详情+借阅
        └── my-books.html                 # 我的借阅
```

---

## 三、数据库设计

### 3.1 表结构

**users 用户表**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INT PK | 自增主键 |
| username | VARCHAR(50) UNIQUE | 用户名 |
| password | VARCHAR(255) | BCrypt加密 |
| role | VARCHAR(20) | super_admin / admin / reader |
| name | VARCHAR(50) | 真实姓名 |
| phone | VARCHAR(20) | 手机号 |
| status | TINYINT | 1=正常 0=禁用 |
| created_at | DATE | 注册日期 |

**books 图书表**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INT PK | 自增主键 |
| isbn | VARCHAR(30) UNIQUE | ISBN编号 |
| title | VARCHAR(200) | 书名 |
| author | VARCHAR(100) | 作者 |
| publisher | VARCHAR(100) | 出版社 |
| category | VARCHAR(50) | 分类 |
| price | DECIMAL(10,2) | 价格 |
| total | INT | 馆藏总数 |
| available | INT | 可借数量 |
| location | VARCHAR(100) | 馆藏位置 |

**borrows 借阅表**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INT PK | 自增主键 |
| book_id | INT FK→books | 外键 |
| user_id | INT FK→users | 外键 |
| status | VARCHAR(20) | applying→borrowed→returned / rejected |
| borrow_date | DATE | 借阅日期 |
| due_date | DATE | 应还日期 |
| return_date | DATE | 实际归还日期(可空) |

```
ER: users(1) ──< borrows >── (1)books
```

### 3.2 种子数据

- 4个用户：admin(超管)、librarian(管理员)、zhangsan(读者)、lisi(读者)
- 36本图书：10个分类（计算机/数据库/网络/文学/历史/科学/数学/外语/哲学/经济）
- 6条借阅记录：2条借阅中 + 1条审核中 + 2条已归还 + 1条已拒绝

---

## 四、核心 API 接口

### 认证

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/auth/login` | 登录，返回 token+user |
| GET | `/api/auth/me` | 当前用户信息 |

### 图书

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/books` | 列表（?keyword=&category=） |
| GET | `/api/books/{id}` | 详情 |
| POST | `/api/books` | 新增 |
| PUT | `/api/books/{id}` | 编辑 |
| DELETE | `/api/books/{id}` | 删除 |

### 借阅

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/borrows` | 列表（?userId=&status=&bookId=） |
| POST | `/api/borrows` | 申请借阅 |
| PUT | `/api/borrows/{id}` | 更新状态（borrowed/rejected/returned） |

### 用户

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/users` | 列表（?role=&keyword=） |
| POST | `/api/users` | 新增 |
| PUT | `/api/users/{id}` | 编辑 |
| DELETE | `/api/users/{id}` | 删除 |

### 统计

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/stats/overview` | 总览（图书数/读者数/借阅中/逾期/趋势图/分类分布） |

---

## 五、核心业务逻辑

### 5.1 借阅库存控制（防竞态）

```
申请借阅 ──→ available -1（立即扣库存）
   ├── 批准 ──→ 不重复扣（已扣过）
   ├── 拒绝 ──→ available +1（还原库存）
   └── 归还 ──→ available +1（还原库存）
```

所有操作在 `@Transactional` 事务中完成。

### 5.2 前端数据流

```
GitHub Pages → USE_MOCK=true  → Mock数据 + localStorage持久化
本地访问    → USE_MOCK=false → http://localhost:8080/api → MySQL
```

`api.js` 自动检测 `location.hostname` 切换模式。

### 5.3 双会话隔离

```
/admin/* → localStorage key: admin_token, admin_user
/front/* → localStorage key: reader_token, reader_user
```

同一浏览器可同时登录管理员和读者，互不干扰。

---

## 六、启动指南

### 后端

```bash
cd backend/
mvn spring-boot:run
# 启动在 http://localhost:8080
```

前置条件：MySQL 8.0 运行中，已执行 `database/init.sql`。

### 前端

直接浏览器打开 `frontend/front/index.html`（读者端）或 `frontend/admin/index.html`（管理端）。

---

## 七、演示账号

| 角色 | 用户名 | 密码 |
|------|--------|------|
| 系统管理员 | admin | admin123 |
| 管理员 | librarian | lib123 |
| 读者 | zhangsan | 123456 |
| 读者 | lisi | 123456 |
