package com.example.catalog.projections;

import org.springframework.data.rest.core.config.Projection;

import com.example.catalog.models.Product;

/** Trims the JSON shape Spring Data REST returns for a Product. */
@Projection(types = { Product.class })
public interface ProductProjection {
	int getId();
	String getName();
	String getCategory();
	String getDescription();
	String getImageUrl();
	int getPrice();
}
