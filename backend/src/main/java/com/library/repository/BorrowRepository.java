package com.library.repository;

import com.library.entity.Borrow;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface BorrowRepository extends JpaRepository<Borrow, Integer> {
    List<Borrow> findByUserIdOrderByIdDesc(Integer userId);
    List<Borrow> findByStatusOrderByIdDesc(String status);
    List<Borrow> findAllByOrderByIdDesc();
    List<Borrow> findByUserIdAndStatusOrderByIdDesc(Integer userId, String status);
    long countByStatus(String status);

    @org.springframework.data.jpa.repository.Query(
        "SELECT b FROM Borrow b WHERE b.status = 'borrowed' AND b.dueDate < CURRENT_DATE")
    List<Borrow> findOverdue();
}
