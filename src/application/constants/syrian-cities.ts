export const SYRIAN_CITIES = [
  'دمشق',
  'ريف دمشق',
  'حلب',
  'حمص',
  'حماة',
  'اللاذقية',
  'دير الزور',
  'الحسكة',
  'درعا',
  'السويداء',
  'القنيطرة',
  'الرقة',
  'طرطوس',
  'إدلب'
] as const;

export type SyrianCity = typeof SYRIAN_CITIES[number];