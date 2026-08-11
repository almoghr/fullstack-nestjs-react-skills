// @ts-nocheck
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';

export type FeatureItemDocument = HydratedDocument<FeatureItem>;

@Schema({ timestamps: true })
export class FeatureItem {
  @Prop({ required: true, trim: true })
  name!: string;

  @Prop({ required: false })
  description?: string;

  createdAt?: Date;
  updatedAt?: Date;
}

export const FeatureItemSchema = SchemaFactory.createForClass(FeatureItem);
