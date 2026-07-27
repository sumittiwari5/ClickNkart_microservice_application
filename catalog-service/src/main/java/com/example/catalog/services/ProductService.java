package com.example.catalog.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import com.example.catalog.models.Product;
import com.example.catalog.models.ProductSpecification;
import com.example.catalog.repositories.ProductRepository;

@Service
public class ProductService {

	@Autowired
	private ProductRepository productRepository;

	public List<String> getAllCategories() {
		return productRepository.findDistinctCategory();
	}

	public List<Product> getProductsByCriteria(String category, String name, Integer maxPrice, String sortDirection, String sortField) {
		Specification<Product> spec = Specification.where(null);
		if (category != null) spec = spec.and(ProductSpecification.hasCategory(category));
		if (name != null) spec = spec.and(ProductSpecification.containingName(name));
		if (maxPrice != null) spec = spec.and(ProductSpecification.priceLessThan(maxPrice));

		Sort sort = Sort.unsorted();
		if (sortDirection != null && sortField != null) {
			Sort.Direction dir = sortDirection.equalsIgnoreCase("desc") ? Sort.Direction.DESC : Sort.Direction.ASC;
			sort = Sort.by(new Sort.Order(dir, sortField));
		}
		return productRepository.findAll(spec, sort);
	}

	/**
	 * Used internally by order-service (via REST) to price a cart line item.
	 * This is the ONE piece of real service-to-service communication in this
	 * "basic" build - order-service calls GET /api/products/{id} on us to
	 * find out the current price of a product, instead of joining across
	 * databases like the old monolith did.
	 */
	public Product getById(int id) {
		return productRepository.findById(id).orElse(null);
	}
}
