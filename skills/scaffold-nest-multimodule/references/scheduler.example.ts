// @ts-nocheck
import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';

@Injectable()
export class BusinessScheduler {
  private readonly logger = new Logger(BusinessScheduler.name);

  @Cron(CronExpression.EVERY_DAY_AT_MIDNIGHT)
  async handleDailyCleanup(): Promise<void> {
    this.logger.log('Executing daily business automated scheduled tasks...');
  }
}
