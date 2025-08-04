enum SortType {
  newest('الأحدث'),
  oldest('الأقدم'),
  priceHighToLow('السعر: من الأعلى للأقل'),
  priceLowToHigh('السعر: من الأقل للأعلى'),
  nameAZ('الاسم: أ-ي'),
  nameZA('الاسم: ي-أ'),
  rating('التقييم'),
  popularity('الأكثر شعبية');

  const SortType(this.displayName);
  
  final String displayName;
  
  String get apiValue {
    switch (this) {
      case SortType.newest:
        return 'createdAt_desc';
      case SortType.oldest:
        return 'createdAt_asc';
      case SortType.priceHighToLow:
        return 'price_desc';
      case SortType.priceLowToHigh:
        return 'price_asc';
      case SortType.nameAZ:
        return 'name_asc';
      case SortType.nameZA:
        return 'name_desc';
      case SortType.rating:
        return 'rating_desc';
      case SortType.popularity:
        return 'popularity_desc';
    }
  }
}