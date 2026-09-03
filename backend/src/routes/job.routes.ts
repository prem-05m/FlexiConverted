import { Router } from 'express';
import multer from 'multer';
import { JobController } from '../controllers/JobController';
import { authenticate } from '../middlewares/auth';

const router = Router();
const upload = multer({ storage: multer.memoryStorage() });

// Protect all job routes
router.use(authenticate);

router.post('/upload', upload.array('files'), JobController.createJob);
router.get('/history', JobController.getHistory);
router.get('/:id/status', JobController.getStatus);
router.delete('/:id', JobController.deleteJob);

export default router;
