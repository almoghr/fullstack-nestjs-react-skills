// @ts-nocheck
import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { BusinessController } from './business.controller';
import { BusinessService } from './business.service';
import { BusinessRepository } from './repository/business.repository';
import { Business, BusinessSchema } from './schemas/business.schema';
import { BusinessFlagsModule } from './modules/business-flags/business-flags.module';
import { BusinessQuestionsModule } from './modules/business-questions/business-questions.module';
import { BusinessScheduler } from './scheduler/business.scheduler';
import { BusinessExcelService } from './services/excel.service';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: Business.name, schema: BusinessSchema }]),
    BusinessFlagsModule,
    BusinessQuestionsModule,
    // Note: Use forwardRef(() => Module) only if a circular dependency incident occurs.
  ],
  controllers: [BusinessController],
  providers: [
    BusinessRepository,
    BusinessService,
    BusinessScheduler,
    BusinessExcelService,
  ],
  exports: [
    BusinessRepository,
    BusinessService,
    BusinessExcelService,
    BusinessFlagsModule,
    BusinessQuestionsModule,
  ],
})
export class BusinessModule { }
