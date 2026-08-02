package com.satish.demo.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.kohsuke.github.GitHub;
import org.kohsuke.github.GitHubBuilder;

import twitter4j.Trend;
import twitter4j.Trends;
import twitter4j.Twitter;
import twitter4j.TwitterException;
import twitter4j.TwitterFactory;
import twitter4j.conf.ConfigurationBuilder;

@RestController
public class RepositoryDetailsController {

    @Autowired
    private Environment env;

    @RequestMapping("/")
    public String getRepos() {
        return "This is the sample DevOps Project";
    }

    @GetMapping("/github-check")
    public String verifyGitHubConnection() {
        try {
            String githubToken = env.getProperty("GITHUB_TOKEN", "mock-token");
            GitHub github = new GitHubBuilder().withOAuthToken(githubToken).build();
            return "GitHub client built successfully. Is Anonymous: " + github.isAnonymous();
        } catch (Exception e) {
            return "GitHub client failed: " + e.getMessage();
        }
    }

    @GetMapping("/trends")
    public Map<String, String> getTwitterTrends(
            @RequestParam("placeid") String trendPlace,
            @RequestParam("count") String trendCount) {

        String consumerKey = env.getProperty("CONSUMER_KEY");
        String consumerSecret = env.getProperty("CONSUMER_SECRET");
        String accessToken = env.getProperty("ACCESS_TOKEN");
        String accessTokenSecret = env.getProperty("ACCESS_TOKEN_SECRET");

        ConfigurationBuilder cb = new ConfigurationBuilder();
        cb.setDebugEnabled(true)
          .setOAuthConsumerKey(consumerKey)
          .setOAuthConsumerSecret(consumerSecret)
          .setOAuthAccessToken(accessToken)
          .setOAuthAccessTokenSecret(accessTokenSecret);

        TwitterFactory tf = new TwitterFactory(cb.build());
        Twitter twitter = tf.getInstance();
        Map<String, String> trendDetails = new HashMap<>();

        try {
            Trends trends = twitter.getPlaceTrends(Integer.parseInt(trendPlace));
            int count = 0;
            for (Trend trend : trends.getTrends()) {
                if (count < Integer.parseInt(trendCount)) {
                    trendDetails.put(trend.getName(), trend.getURL());
                    count++;
                }
            }
        } catch (TwitterException e) {
            trendDetails.put("test", "MyTweetException: " + e.getMessage());
        } catch (Exception e) {
            trendDetails.put("test", "GeneralException: " + e.getMessage());
        }

        return trendDetails;
    }
}
