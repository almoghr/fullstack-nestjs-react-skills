#!/usr/bin/env bash
set -e

# Script to scaffold a NestJS module with standard custom directories:
# dto/, constants/, repositories/, schemas/

FEATURE_NAME="$1"

if [ -z "$FEATURE_NAME" ]; then
  echo "Usage: ./scaffold-module.sh <feature-name> [backend-path]"
  echo "Example: ./scaffold-module.sh products polytech-bgf-backend"
  exit 1
fi

TARGET_DIR="${2:-polytech-bgf-backend}"

if [ ! -d "$TARGET_DIR/src" ] && [ -d "src" ]; then
  MODULE_ROOT="src/$FEATURE_NAME"
else
  MODULE_ROOT="$TARGET_DIR/src/$FEATURE_NAME"
fi

echo "=== Scaffolding NestJS Module: $FEATURE_NAME ==="

# Check Nest CLI
NEST_CMD=""
if command -v nest >/dev/null 2>&1; then
  NEST_CMD="nest"
elif command -v pnpm >/dev/null 2>&1 && pnpm exec nest --version >/dev/null 2>&1; then
  NEST_CMD="pnpm exec nest"
else
  NEST_CMD="npx nest"
fi

# Determine singular name (basic singularization helper)
SINGULAR_NAME=$(echo "$FEATURE_NAME" | sed 's/s$//')
UPPER_FEATURE=$(echo "$FEATURE_NAME" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
PASCAL_SINGULAR="$(echo "${SINGULAR_NAME:0:1}" | tr '[:lower:]' '[:upper:]')"${SINGULAR_NAME:1}
PASCAL_FEATURE="$(echo "${FEATURE_NAME:0:1}" | tr '[:lower:]' '[:upper:]')"${FEATURE_NAME:1}

echo "Feature: $FEATURE_NAME (Singular: $SINGULAR_NAME)"
echo "Module Root Path: $MODULE_ROOT"

# 1. Create subdirectories
mkdir -p "$MODULE_ROOT/dto"
mkdir -p "$MODULE_ROOT/constants"
mkdir -p "$MODULE_ROOT/repositories"
mkdir -p "$MODULE_ROOT/schemas"

# 2. Create Constants File
CONSTANTS_FILE="$MODULE_ROOT/constants/$FEATURE_NAME.constants.ts"
if [ ! -f "$CONSTANTS_FILE" ]; then
  cat <<EOF > "$CONSTANTS_FILE"
export const ${UPPER_FEATURE}_MESSAGES = {
  NOT_FOUND: '${PASCAL_SINGULAR} not found',
  CREATED_SUCCESSFULLY: '${PASCAL_SINGULAR} created successfully',
  UPDATED_SUCCESSFULLY: '${PASCAL_SINGULAR} updated successfully',
  DELETED_SUCCESSFULLY: '${PASCAL_SINGULAR} deleted successfully',
} as const;

export const ${UPPER_FEATURE}_DEFAULTS = {
  DEFAULT_PAGE: 1,
  DEFAULT_LIMIT: 10,
} as const;
EOF
  echo "Created: $CONSTANTS_FILE"
fi

# 3. Create Schema File
SCHEMA_FILE="$MODULE_ROOT/schemas/$SINGULAR_NAME.schema.ts"
if [ ! -f "$SCHEMA_FILE" ]; then
  cat <<EOF > "$SCHEMA_FILE"
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';

export type ${PASCAL_SINGULAR}Document = HydratedDocument<${PASCAL_SINGULAR}>;

@Schema({ timestamps: true })
export class ${PASCAL_SINGULAR} {
  @Prop({ required: true })
  name: string;

  @Prop()
  description?: string;
}

export const ${PASCAL_SINGULAR}Schema = SchemaFactory.createForClass(${PASCAL_SINGULAR});
EOF
  echo "Created: $SCHEMA_FILE"
fi

# 4. Create Repository Files
REPO_FILE="$MODULE_ROOT/repositories/$FEATURE_NAME.repository.ts"
if [ ! -f "$REPO_FILE" ]; then
  cat <<EOF > "$REPO_FILE"
import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { ${PASCAL_SINGULAR}, ${PASCAL_SINGULAR}Document } from '../schemas/$SINGULAR_NAME.schema';

@Injectable()
export class ${PASCAL_FEATURE}Repository {
  constructor(
    @InjectModel(${PASCAL_SINGULAR}.name)
    private readonly ${SINGULAR_NAME}Model: Model<${PASCAL_SINGULAR}Document>,
  ) {}

  async create(data: Partial<${PASCAL_SINGULAR}>): Promise<${PASCAL_SINGULAR}> {
    const created = new this.${SINGULAR_NAME}Model(data);
    return created.save();
  }

  async findAll(): Promise<${PASCAL_SINGULAR}[]> {
    return this.${SINGULAR_NAME}Model.find().exec();
  }

  async findById(id: string): Promise<${PASCAL_SINGULAR} | null> {
    return this.${SINGULAR_NAME}Model.findById(id).exec();
  }
}
EOF
  echo "Created: $REPO_FILE"
fi

# 5. Create DTO Files
CREATE_DTO="$MODULE_ROOT/dto/create-$SINGULAR_NAME.dto.ts"
if [ ! -f "$CREATE_DTO" ]; then
  cat <<EOF > "$CREATE_DTO"
import { IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class Create${PASCAL_SINGULAR}Dto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
  @IsOptional()
  description?: string;
}
EOF
  echo "Created: $CREATE_DTO"
fi

UPDATE_DTO="$MODULE_ROOT/dto/update-$SINGULAR_NAME.dto.ts"
if [ ! -f "$UPDATE_DTO" ]; then
  cat <<EOF > "$UPDATE_DTO"
import { IsOptional, IsString } from 'class-validator';

export class Update${PASCAL_SINGULAR}Dto {
  @IsString()
  @IsOptional()
  name?: string;

  @IsString()
  @IsOptional()
  description?: string;
}
EOF
  echo "Created: $UPDATE_DTO"
fi


echo "=== NestJS Module $FEATURE_NAME scaffolded successfully ==="
