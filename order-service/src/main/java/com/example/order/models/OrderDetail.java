package com.example.order.models;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;

@Entity
public class OrderDetail {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private int id;

	// Orders stays a normal JPA relation - both tables live in THIS
	// service's database, so this one is still a real, valid foreign key.
	@ManyToOne
	@JoinColumn
	private Orders orders;

	// Product does NOT live in this database anymore - plain id only.
	private int productId;
	private int quantity;

	public int getId() { return id; }
	public void setId(int id) { this.id = id; }
	public Orders getOrders() { return orders; }
	public void setOrders(Orders orders) { this.orders = orders; }
	public int getProductId() { return productId; }
	public void setProductId(int productId) { this.productId = productId; }
	public int getQuantity() { return quantity; }
	public void setQuantity(int quantity) { this.quantity = quantity; }
}
