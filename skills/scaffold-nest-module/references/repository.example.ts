// @ts-nocheck
import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { FeatureItem, FeatureItemDocument } from '../schemas/feature-item.schema';

@Injectable()
export class FeatureRepository {
  constructor(
    @InjectModel(FeatureItem.name)
    private readonly itemModel: Model<FeatureItemDocument>,
  ) {}

  async create(data: Partial<FeatureItem>): Promise<FeatureItemDocument> {
    const created = new this.itemModel(data);
    return created.save();
  }

  async findAll(): Promise<FeatureItemDocument[]> {
    return this.itemModel.find().exec();
  }

  async findById(id: string): Promise<FeatureItemDocument | null> {
    return this.itemModel.findById(id).exec();
  }

  async update(id: string, updateData: Partial<FeatureItem>): Promise<FeatureItemDocument | null> {
    return this.itemModel
      .findByIdAndUpdate(id, updateData, { returnDocument: 'after' })
      .exec();
  }

  async delete(id: string): Promise<FeatureItemDocument | null> {
    return this.itemModel.findByIdAndDelete(id).exec();
  }
}
