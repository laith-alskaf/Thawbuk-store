export interface GetFilteredProductsParams {
    category?: string;
    searchQuery?: string;
    sizes?: string[];
    colors?: string[];
    minPrice?: number;
    maxPrice?: number;
    sortBy?: string;
}
