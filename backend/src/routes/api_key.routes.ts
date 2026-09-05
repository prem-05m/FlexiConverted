import { Router } from 'express';
import { getCloudConvertKey } from '../controllers/ApiKeyController';

const router = Router();

// GET /api/v1/keys/cloudconvert
router.get('/cloudconvert', getCloudConvertKey);

export default router;
