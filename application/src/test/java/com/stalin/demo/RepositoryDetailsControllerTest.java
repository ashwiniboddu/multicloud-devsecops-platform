package com.stalin.demo;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import static org.junit.jupiter.api.Assertions.assertEquals;

public class RepositoryDetailsControllerTest extends AbstractTest {

    @Override
    @BeforeEach
    public void setUp() {
        super.setUp();
    }

    @Test
    public void getProductsList() throws Exception {
        // STEP 1 FIX: Change the path string to match your real code routing
        String uri = "/"; 
        
        MvcResult mvcResult = mvc.perform(MockMvcRequestBuilders.get(uri)
           .accept(MediaType.APPLICATION_JSON_VALUE)).andReturn();
        
        int status = mvcResult.getResponse().getStatus();
        assertEquals(200, status);
    }
}
