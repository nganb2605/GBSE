package demo.controller;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.web.servlet.MockMvc;

import demo.dto.ProductSearchItem;
import demo.model.Category;
import demo.model.Product;
import demo.service.CategoryService;
import demo.service.ContactRateLimiter;
import demo.service.ContactRequestService;
import demo.service.ProductService;

@WebMvcTest(PublicController.class)
@AutoConfigureMockMvc(addFilters = false)
class CatalogueRenderTest {

    @Autowired MockMvc mvc;
    @MockBean ProductService products;
    @MockBean CategoryService categories;
    @MockBean ContactRequestService requests;
    @MockBean ContactRateLimiter limiter;

    private static Category category(String name, String slug, Category parent) {
        Category c = new Category();
        c.setName(name);
        c.setSlug(slug);
        c.setParent(parent);
        if (parent != null) parent.getChildren().add(c);
        return c;
    }

    @Test
    void catalogueShowsTwoAndThreeLevelGroupsWithOnlyProductCards() throws Exception {
        Category root = category("Metering and Measuring", "metering", null);
        Category water = category("Water Meter", "water-meter", root);
        water.setApplications("[\"Cold Water & Hot water supply system\"]");
        water.setSpecs("[{\"label\":\"Pressure\",\"value\":\"16 bar\"}]");
        water.setDocuments("[{\"label\":\"Catalogue\",\"url\":\"/docs/mag-c.pdf\"}]");
        Category meterFolder = category("DN15-20 Single Jet", "single-jet", water);
        Product meter = new Product();
        meter.setId(5L);
        meter.setName("Water meter DN15-20 single jet");
        meter.setSpecs("[{\"label\":\"Model\",\"value\":\"GSD8-RFM\"}]");
        meter.setCategories(List.of(meterFolder));
        meterFolder.setProducts(List.of(meter));
        Category multiJet = category("DN15-50 Multi Jet", "multi-jet", water);
        Product longName = new Product();
        longName.setId(7L);
        longName.setName("Water meter DN15-50 multi jet with a long product name");
        multiJet.setProducts(List.of(longName));
        Category largeMeter = category("DN50-200", "large-meter", water);
        Product thirdMeter = new Product();
        thirdMeter.setId(8L);
        thirdMeter.setName("Water meter DN50-200");
        largeMeter.setProducts(List.of(thirdMeter));
        Category heatpump = category("heatpump", "Heatpump", null);
        Category airSource = category("air-source", "Heatpump Air Source", heatpump);
        Category cahp = category("CAHP", "cahp", airSource);
        Product pump = new Product();
        pump.setId(6L);
        pump.setName("CAHP");
        cahp.setProducts(List.of(pump));
        Category plateRange = category("Plate Heat Exchanger", "phe", null);
        Category plateFolder = category("Plate Heat Exchanger", "phe-product", plateRange);
        Product plate = new Product();
        plate.setId(9L);
        plate.setName("Plate Heat Exchanger");
        plateFolder.setProducts(List.of(plate));
        when(categories.getRoots()).thenReturn(List.of(root, heatpump, plateRange));
        when(categories.getNavigationRoots()).thenReturn(List.of(root, heatpump, plateRange));
        when(products.findAllForSearch()).thenReturn(List.of(
            new ProductSearchItem(5L, meter.getName(), "", meter.getImage(), meter.getSearchText())));

        String html = mvc.perform(get("/products"))
            .andExpect(status().isOk())
            .andExpect(content().string(org.hamcrest.Matchers.containsString("<section class=\"catalogue-group\"")))
            .andExpect(content().string(org.hamcrest.Matchers.not(org.hamcrest.Matchers.containsString("<details class=\"catalogue-group\""))))
            .andExpect(content().string(org.hamcrest.Matchers.containsString("Water meter DN15-20 single jet")))
            .andExpect(content().string(org.hamcrest.Matchers.containsString("Heatpump Air Source")))
            .andExpect(content().string(org.hamcrest.Matchers.containsString(longName.getName())))
            .andExpect(content().string(org.hamcrest.Matchers.containsString("/images/placeholder.png")))
            .andExpect(content().string(org.hamcrest.Matchers.not(org.hamcrest.Matchers.containsString("16 bar"))))
            .andExpect(content().string(org.hamcrest.Matchers.not(org.hamcrest.Matchers.containsString("/docs/mag-c.pdf"))))
            .andReturn().getResponse().getContentAsString();
        assertEquals(5, html.split("class=\"prod-card\"", -1).length - 1);
        assertEquals(5, html.split("<span>View product</span>", -1).length - 1);
        assertEquals(3, html.split("class=\"product-grid\"", -1).length - 1);
    }

    @Test
    void productDetailRendersFeaturesAndBreadcrumb() throws Exception {
        Category root = category("Metering and Measuring", "metering", null);
        Category water = category("Water Meter", "water-meter", root);
        Product meter = new Product();
        meter.setId(5L);
        meter.setName("Water meter DN15-20 single jet");
        meter.setCategories(List.of(water));
        meter.setDescription("Brand name: BMETERS\nWorking pressure: 16 bar\nBRAND NAME : Hidden brand");
        meter.setFeatures("[\"Anti magnetic fraud protection\"]");
        meter.setSpecs("[{\"label\":\"Model\",\"value\":\"GSD8-RFM\"}]");
        meter.setDocuments("[{\"label\":\"RFM-MB1\",\"url\":\"/docs/rfm-mb1.pdf\"},{\"label\":\"RFM-TX1\",\"url\":\"/docs/rfm-tx1.pdf\"}]");
        when(categories.getRoots()).thenReturn(List.of(root));
        when(categories.getNavigationRoots()).thenReturn(List.of(root));
        when(products.findById(5L)).thenReturn(Optional.of(meter));

        mvc.perform(get("/products/5"))
            .andExpect(status().isOk())
            .andExpect(content().string(org.hamcrest.Matchers.containsString("Anti magnetic fraud protection")))
            .andExpect(content().string(org.hamcrest.Matchers.containsString("Working pressure: 16 bar")))
            .andExpect(content().string(org.hamcrest.Matchers.not(org.hamcrest.Matchers.containsString("<li>Brand name: BMETERS</li>"))))
            .andExpect(content().string(org.hamcrest.Matchers.not(org.hamcrest.Matchers.containsString("<li>BRAND NAME : Hidden brand</li>"))))
            .andExpect(content().string(org.hamcrest.Matchers.matchesPattern("(?s).*class=\"detail-header\".*<h1[^>]*>.*?</h1>\\s*<a href=\"/contact\"[^>]*>Contact Us</a>\\s*</div>.*")))
            .andExpect(content().string(org.hamcrest.Matchers.containsString("/products#cat-water-meter")))
            .andExpect(content().string(org.hamcrest.Matchers.containsString("/docs/rfm-mb1.pdf")))
            .andExpect(content().string(org.hamcrest.Matchers.containsString("/docs/rfm-tx1.pdf")));
    }

    @Test
    void sitemapIncludesOnlyVisibleProductsReturnedByService() throws Exception {
        Product product = new Product();
        product.setId(5L);
        when(products.findAll()).thenReturn(List.of(product));
        when(categories.getRoots()).thenReturn(List.of());

        mvc.perform(get("/sitemap.xml"))
            .andExpect(status().isOk())
            .andExpect(content().string(org.hamcrest.Matchers.containsString("/products/5</loc>")));
    }
}
