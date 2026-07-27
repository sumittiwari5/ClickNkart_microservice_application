package com.example.order.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

import com.example.order.models.Orders;
import com.example.order.projections.OrderProjection;

@RepositoryRestResource(excerptProjection = OrderProjection.class)
public interface OrdersRepository extends JpaRepository<Orders, String> {
}
