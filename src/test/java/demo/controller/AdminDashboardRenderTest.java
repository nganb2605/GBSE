package demo.controller;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.data.domain.PageImpl;
import org.springframework.security.web.csrf.DefaultCsrfToken;
import org.springframework.test.web.servlet.MockMvc;

import demo.model.ContactRequest;
import demo.service.CategoryService;
import demo.service.ContactRequestService;
import demo.service.DashboardService;

@WebMvcTest(AdminDashboardController.class)
@AutoConfigureMockMvc(addFilters = false)
class AdminDashboardRenderTest {
    @Autowired MockMvc mvc;
    @MockBean DashboardService dashboard;
    @MockBean ContactRequestService requests;
    @MockBean CategoryService categories;

    @Test
    void rendersPopulatedDashboardWithoutLoadingCatalogue() throws Exception {
        ContactRequest request = new ContactRequest();
        request.setId(1L);
        request.setFullName("Test customer");
        request.setCreatedAt(LocalDateTime.of(2026, 10, 1, 10, 0));
        when(dashboard.getDashboardData(any(), any())).thenReturn(Map.of(
            "hasData", true, "totalRequests", 1L,
            "chartLabels", List.of("01/10"), "chartRequestData", List.of(1L)));
        when(requests.findPage(null, null, 0)).thenReturn(new PageImpl<>(List.of(request)));

        mvc.perform(get("/admin").servletPath("/admin")
                .requestAttr("_csrf", new DefaultCsrfToken("X-CSRF-TOKEN", "_csrf", "test")))
            .andExpect(status().isOk())
            .andExpect(content().string(org.hamcrest.Matchers.containsString("Test customer")));
        verifyNoInteractions(categories);
    }
}
