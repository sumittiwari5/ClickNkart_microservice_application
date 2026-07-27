package com.example.order.models;

import java.time.LocalDateTime;

import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.Id;

@Entity
@EntityListeners(AuditingEntityListener.class)
public class Orders {
	@Id
	private String orderId;
	private String paymentId;
	@CreatedDate
	private LocalDateTime orderDate;

	// was a @ManyToOne User before - now just the id, taken from the JWT
	private int userId;
	private int totalBill;

	public String getOrderId() { return orderId; }
	public void setOrderId(String orderId) { this.orderId = orderId; }
	public String getPaymentId() { return paymentId; }
	public void setPaymentId(String paymentId) { this.paymentId = paymentId; }
	public LocalDateTime getOrderDate() { return orderDate; }
	public void setOrderDate(LocalDateTime orderDate) { this.orderDate = orderDate; }
	public int getUserId() { return userId; }
	public void setUserId(int userId) { this.userId = userId; }
	public int getTotalBill() { return totalBill; }
	public void setTotalBill(int totalBill) { this.totalBill = totalBill; }
}
