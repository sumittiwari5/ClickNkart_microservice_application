package com.example.order.repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.order.models.OrderDetail;
import com.example.order.models.Orders;

public interface OrderDetailRepository extends JpaRepository<OrderDetail, Integer> {
	List<OrderDetail> findAllByOrders(Orders orders);
}
