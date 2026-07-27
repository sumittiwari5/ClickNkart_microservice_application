package com.example.order.models;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

/**
 * MICROSERVICE NOTE: the original Cart had @ManyToOne relations straight to
 * User and Product entities, because everything lived in one database. That
 * is exactly the kind of coupling a microservice split has to break: this
 * service's database has no "users" or "products" table anymore, so we
 * store plain userId/productId integers instead, and fetch anything else we
 * need (like current price) over the network via ProductClient.
 */
@Entity
public class Cart {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private int id;

	private int quantity = 1;
	private int userId;
	private int productId;

	public int getId() { return id; }
	public void setId(int id) { this.id = id; }
	public int getQuantity() { return quantity; }
	public void setQuantity(int quantity) { this.quantity = quantity; }
	public int getUserId() { return userId; }
	public void setUserId(int userId) { this.userId = userId; }
	public int getProductId() { return productId; }
	public void setProductId(int productId) { this.productId = productId; }
}
