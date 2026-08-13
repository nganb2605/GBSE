package demo.dto;

/** The only product fields the catalogue search box needs. */
public record ProductSearchItem(Long id, String name, String shortText, String image) {}
