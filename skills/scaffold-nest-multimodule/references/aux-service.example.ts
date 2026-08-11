// @ts-nocheck
import { Injectable } from '@nestjs/common';
import { BusinessRepository } from '../repository/business.repository';

@Injectable()
export class BusinessExcelService {
  constructor(private readonly businessRepository: BusinessRepository) { }

  async generateExcelReport(): Promise<Buffer> {
    const businesses = await this.businessRepository.findAll();
    // Logic to construct and return binary spreadsheet buffer
    return Buffer.from(`Report summary for ${businesses.length} items`);
  }
}
