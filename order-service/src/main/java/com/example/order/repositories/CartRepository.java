package com.example.order.repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

import com.example.order.models.Cart;

@RepositoryRestResource
public interface CartRepository extends JpaRepository<Cart, Integer> {
	List<Cart> findAllByUserId(int userId);
}
