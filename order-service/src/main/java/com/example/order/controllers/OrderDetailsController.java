package com.example.order.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import com.example.order.services.OrderDetailService;

@RestController
public class OrderDetailsController {

	@Autowired
	private OrderDetailService service;

	@GetMapping("/api/orderDetails/{orderId}")
	public ResponseEntity<?> getOrderDetails(@PathVariable String orderId) {
		return new ResponseEntity<>(service.getAllOrderDetails(orderId), HttpStatus.OK);
	}
}
