package com.bdms.config;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;

/**
 * Keeps the app awake on Render's free plan (it sleeps after ~15 minutes without
 * incoming traffic). Every 10 minutes the app calls its own public URL, which
 * counts as incoming traffic. Render sets RENDER_EXTERNAL_URL automatically;
 * when it is absent (local runs) nothing happens.
 */
@Configuration
@EnableScheduling
public class KeepAliveScheduler {

	private static final Logger log = LoggerFactory.getLogger(KeepAliveScheduler.class);

	private final HttpClient client = HttpClient.newBuilder()
			.connectTimeout(Duration.ofSeconds(10))
			.build();

	@Value("${app.keepalive.url:${RENDER_EXTERNAL_URL:}}")
	private String baseUrl;

	// 10 minutes; first run 10 minutes after startup.
	@Scheduled(fixedDelay = 600_000, initialDelay = 600_000)
	public void pingSelf() {
		if (baseUrl == null || baseUrl.isBlank()) {
			return;
		}
		try {
			String url = baseUrl.endsWith("/") ? baseUrl + "login" : baseUrl + "/login";
			HttpRequest request = HttpRequest.newBuilder(URI.create(url))
					.timeout(Duration.ofSeconds(30)).GET().build();
			HttpResponse<Void> response = client.send(request, HttpResponse.BodyHandlers.discarding());
			log.info("Keep-alive ping {} -> {}", url, response.statusCode());
		} catch (InterruptedException e) {
			Thread.currentThread().interrupt();
		} catch (Exception e) {
			log.warn("Keep-alive ping failed: {}", e.getMessage());
		}
	}
}
