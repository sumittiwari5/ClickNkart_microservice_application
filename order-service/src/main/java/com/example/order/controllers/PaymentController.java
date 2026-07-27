package com.example.order.controllers;

import java.util.Map;

import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.example.order.models.Orders;
import com.example.order.services.OrderService;
import com.razorpay.Order;
import com.razorpay.RazorpayClient;
import com.razorpay.Utils;

@RestController
public class PaymentController {

	@Value("${razorpay.key_id}")
	private String keyId;

	@Value("${razorpay.key_secret}")
	private String keySecret;

	@Autowired
	private OrderService orderService;

	@PostMapping("/api/create-order")
	public ResponseEntity<?> createRazorpayOrder(@RequestBody Map<String, Object> data) {
		try {
			int amount = (int) data.get("amount");
			RazorpayClient client = new RazorpayClient(keyId, keySecret);

			JSONObject orderRequest = new JSONObject();
			orderRequest.put("amount", amount * 100);
			orderRequest.put("currency", "INR");
			orderRequest.put("receipt", "txn_12345");

			Order order = client.orders.create(orderRequest);
			return new ResponseEntity<>(Map.of("orderId", order.get("id"), "key", keyId), HttpStatus.OK);
		} catch (Exception e) {
			return new ResponseEntity<>("Error:" + e.getMessage(), HttpStatus.BAD_REQUEST);
		}
	}

	@PostMapping("/api/verify")
	public ResponseEntity<?> verifyPayment(Authentication authentication, @RequestBody Map<String, String> data) {
		try {
			// MICROSERVICE NOTE: the old @AuthenticationPrincipal User user
			// doesn't work here anymore - order-service has no User entity
			// or user table to load. The JWT filter (see security/) puts
			// the numeric userId straight into the Authentication's name,
			// taken directly from the token, since that's all this service
			// needs to know about "who" placed the order.
			int userId = Integer.parseInt(authentication.getName());

			String orderId = data.get("razorpay_order_id");
			String paymentId = data.get("razorpay_payment_id");
			String signature = data.get("razorpay_signature");
			String generatedSignature = Utils.getHash(orderId + "|" + paymentId, keySecret);

			if (generatedSignature.equals(signature)) {
				Orders o = new Orders();
				o.setOrderId(orderId);
				o.setPaymentId(paymentId);
				o.setUserId(userId);
				orderService.placeOrder(o);
				return ResponseEntity.ok("Payment Verified");
			} else {
				return ResponseEntity.status(400).body("Invalid Signature");
			}
		} catch (Exception e) {
			return ResponseEntity.badRequest().body("Error: " + e.getMessage());
		}
	}
}
