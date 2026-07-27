package com.example.order.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.order.models.OrderDetail;
import com.example.order.models.Orders;
import com.example.order.repositories.OrderDetailRepository;
import com.example.order.repositories.OrdersRepository;

@Service
public class OrderDetailService {

	@Autowired
	private OrderDetailRepository orderDetailRepository;
	@Autowired
	private OrdersRepository ordersRepository;

	public List<OrderDetail> getAllOrderDetails(String orderId) {
		Orders o = ordersRepository.findById(orderId).get();
		return orderDetailRepository.findAllByOrders(o);
	}
}
