package com.example.order.clients;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

/**
 * The ONE real piece of service-to-service networking in this build.
 * order-service does not have its own copy of product data (that would
 * defeat the point of splitting it out), so whenever it needs a price it
 * asks catalog-service directly over HTTP, inside the cluster, using the
 * catalog-service's Kubernetes Service DNS name.
 *
 * This is the simplest possible inter-service communication pattern
 * (synchronous REST call). Once you're comfortable with this, the natural
 * next step to explore is asynchronous messaging (e.g. RabbitMQ/Kafka) so
 * order-service doesn't fail outright if catalog-service is briefly down.
 */
@Component
public class ProductClient {

	@Value("${catalog.service.url}")
	private String catalogServiceUrl;

	private final RestClient restClient = RestClient.create();

	public record ProductInfo(int id, String name, int price, String imageUrl) {}

	public ProductInfo getProduct(int productId) {
		return restClient.get()
				.uri(catalogServiceUrl + "/api/products/{id}/internal", productId)
				.retrieve()
				.body(ProductInfo.class);
	}
}
