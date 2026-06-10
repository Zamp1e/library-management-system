package com.library.entity;

import jakarta.persistence.*;
import java.time.LocalDate;

/**
 * 借阅记录实体类，映射 borrows 表
 *
 * 状态流转：applying（审核中）→ borrowed（借阅中）→ returned（已归还）
 *                           ↘ rejected（已拒绝）
 *
 * bookTitle 和 userName 为 @Transient 字段，
 * 不存入数据库，由 Service 层在查询时 JOIN 填充，用于前端展示。
 */
@Entity
@Table(name = "borrows")
public class Borrow {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "book_id", nullable = false)
    private Integer bookId;

    @Column(name = "user_id", nullable = false)
    private Integer userId;

    @Column(nullable = false, length = 20)
    private String status; // applying / borrowed / returned / rejected

    @Column(name = "borrow_date", nullable = false)
    private LocalDate borrowDate;

    @Column(name = "due_date", nullable = false)
    private LocalDate dueDate;

    @Column(name = "return_date")
    private LocalDate returnDate;

    @Transient
    private String bookTitle;

    @Transient
    private String userName;

    public Borrow() {}

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public Integer getBookId() { return bookId; }
    public void setBookId(Integer bookId) { this.bookId = bookId; }
    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDate getBorrowDate() { return borrowDate; }
    public void setBorrowDate(LocalDate borrowDate) { this.borrowDate = borrowDate; }
    public LocalDate getDueDate() { return dueDate; }
    public void setDueDate(LocalDate dueDate) { this.dueDate = dueDate; }
    public LocalDate getReturnDate() { return returnDate; }
    public void setReturnDate(LocalDate returnDate) { this.returnDate = returnDate; }
    public String getBookTitle() { return bookTitle; }
    public void setBookTitle(String bookTitle) { this.bookTitle = bookTitle; }
    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }
}
