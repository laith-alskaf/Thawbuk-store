import { Router } from 'express';
import { CitiesController } from '../controllers/cities.controller';

const citiesRoutes = (): Router => {
  const router = Router();
  const citiesController = new CitiesController();

  router.get('/syrian-cities', citiesController.getSyrianCities.bind(citiesController));

  return router;
};

export default citiesRoutes;