import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { BusinessFlagsController } from './business-flags.controller';
import { BusinessFlagsService } from './business-flags.service';
import { BusinessFlagsRepository } from './repository/business-flags.repository';
import { BusinessFlags, BusinessFlagsSchema } from './schemas/business-flags.schema';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: BusinessFlags.name, schema: BusinessFlagsSchema }]),
    // Note: Standard module import is used by default. Use forwardRef(() => ParentModule) only if circular dependency occurs.
  ],
  controllers: [BusinessFlagsController],
  providers: [BusinessFlagsRepository, BusinessFlagsService],
  exports: [BusinessFlagsRepository, BusinessFlagsService],
})
export class BusinessFlagsModule {}
