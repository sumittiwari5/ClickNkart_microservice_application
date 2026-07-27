package com.example.order.projections;

import java.time.LocalDateTime;

import org.springframework.data.rest.core.config.Projection;

import com.example.order.models.Orders;

@Projection(types = { Orders.class })
public interface OrderProjection {
	String getOrderId();
	String getPaymentId();
	LocalDateTime getOrderDate();
	int getTotalBill();
}
