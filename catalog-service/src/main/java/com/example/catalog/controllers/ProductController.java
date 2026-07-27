package com.example.catalog.controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.catalog.models.Product;
import com.example.catalog.services.ProductService;

@RestController
public class ProductController {

	@Autowired
	private ProductService service;

	@GetMapping("/api/categories")
	public ResponseEntity<?> getAllCategories() {
		return new ResponseEntity<>(service.getAllCategories(), HttpStatus.OK);
	}

	@GetMapping("/api/search-products")
	public ResponseEntity<?> getProductsByCriteria(
			@RequestParam(name = "name", required = false) String name,
			@RequestParam(name = "category", required = false) String category,
			@RequestParam(name = "maxPrice", required = false) Integer maxPrice,
			@RequestParam(name = "direction", required = false) String sortDirection) {
		List<Product> allProducts = service.getProductsByCriteria(category, name, maxPrice, sortDirection, "price");
		return new ResponseEntity<>(allProducts, HttpStatus.OK);
	}

	/**
	 * Internal lookup endpoint - order-service calls this to price cart
	 * items and build order lines. Not something the frontend needs to call
	 * directly (Spring Data REST also exposes /api/products/{id} publicly,
	 * which the frontend product-detail page can use).
	 */
	@GetMapping("/api/products/{id}/internal")
	public ResponseEntity<?> getProductInternal(@PathVariable int id) {
		Product p = service.getById(id);
		if (p == null) return new ResponseEntity<>(HttpStatus.NOT_FOUND);
		return new ResponseEntity<>(p, HttpStatus.OK);
	}
}
