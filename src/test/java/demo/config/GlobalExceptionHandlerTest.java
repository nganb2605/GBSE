package demo.config;

import static org.junit.jupiter.api.Assertions.*;

import java.io.IOException;

import org.apache.catalina.connector.ClientAbortException;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.web.servlet.ModelAndView;

class GlobalExceptionHandlerTest {
    private final GlobalExceptionHandler handler = new GlobalExceptionHandler();

    @Test
    void abortedFileTransferDoesNotAttemptHtmlRendering() throws Exception {
        MockHttpServletResponse response = new MockHttpServletResponse();
        response.getOutputStream().write(new byte[16]);
        response.flushBuffer();
        ModelAndView result = handler.handle500(
            new ClientAbortException(new IOException("Connection reset by peer")), response);
        assertTrue(result.isEmpty());
        assertEquals(16, response.getContentAsByteArray().length);
    }

    @Test
    void committedResponseDoesNotAttemptAnotherRender() throws Exception {
        MockHttpServletResponse response = new MockHttpServletResponse();
        response.flushBuffer();
        assertTrue(handler.handle500(new IllegalStateException("late failure"), response).isEmpty());
    }

    @Test
    void serverAndMissingResourceErrorsHaveCorrectStatus() {
        ModelAndView result = handler.handle500(
            new IllegalStateException("failure"), new MockHttpServletResponse());
        assertEquals("error/500", result.getViewName());
        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, result.getStatus());
        assertEquals(HttpStatus.NOT_FOUND, handler.handle404().getStatus());
    }
}
