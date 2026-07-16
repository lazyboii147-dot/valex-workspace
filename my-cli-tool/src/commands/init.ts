import { Command } from 'commander';
import { logger } from '../ui/logger';
export const initCommand = new Command('init').action(() => {
  logger.info('Initializing workspace...');
  logger.success('Workspace initialization complete.');
});
