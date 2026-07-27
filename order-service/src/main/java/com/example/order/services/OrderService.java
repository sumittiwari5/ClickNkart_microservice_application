package com.example.order.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.order.clients.ProductClient;
import com.example.order.clients.ProductClient.ProductInfo;
import com.example.order.models.Cart;
import com.example.order.models.OrderDetail;
import com.example.order.models.Orders;
import com.example.order.repositories.CartRepository;
import com.example.order.repositories.OrderDetailRepository;
import com.example.order.repositories.OrdersRepository;

@Service
public class OrderService {

	@Autowired
	private OrdersRepository ordersRepository;
	@Autowired
	private OrderDetailRepository orderDetailRepository;
	@Autowired
	private CartRepository cartRepository;
	@Autowired
	private ProductClient productClient;

	/**
	 * Same overall flow as the monolith's placeOrder(), but every price
	 * lookup that used to be a simple Java field access (cart.getProduct()
	 * .getPrice()) is now a real network call to catalog-service, because
	 * that's where product data actually lives now. This is the trade-off
	 * microservices make: better separation of concerns, at the cost of
	 * needing the network to be up between services.
	 */
	public void placeOrder(Orders orders) {
		List<Cart> cartList = cartRepository.findAllByUserId(orders.getUserId());

		int totalBill = 0;
		for (Cart cart : cartList) {
			ProductInfo product = productClient.getProduct(cart.getProductId());
			totalBill += product.price() * cart.getQuantity();
		}
		orders.setTotalBill(totalBill);
		ordersRepository.save(orders);

		List<OrderDetail> details = cartList.stream().map(cart -> {
			OrderDetail o = new OrderDetail();
			o.setOrders(orders);
			o.setProductId(cart.getProductId());
			o.setQuantity(cart.getQuantity());
			return o;
		}).toList();

		orderDetailRepository.saveAll(details);
		cartRepository.deleteAll(cartList);
	}
}
