#!/usr/bin/env bash
set -e

# Script to scaffold a Multi-Module (Composite) NestJS Feature Structure
# Features included:
# - Core parent module with dto/, constants/, repository/, schemas/, enums/, types/, services/, scheduler/, modules/
# - Sub-modules nested under modules/<sub-feature-name>/ with standard module imports (forwardRef only if circular dependency occurs)

FEATURE_NAME="$1"
SUBMODULES_CSV="$2"
TARGET_DIR="${3:-polytech-bgf-backend}"

if [ -z "$FEATURE_NAME" ]; then
  echo "Usage: ./scaffold-multi-module.sh <parent-feature-name> [submodules-comma-separated] [target-dir]"
  echo "Example: ./scaffold-multi-module.sh business business-flags,business-questions,restaurant-questions"
  exit 1
fi

if [ ! -d "$TARGET_DIR/src" ] && [ -d "src" ]; then
  MODULE_ROOT="src/$FEATURE_NAME"
else
  MODULE_ROOT="$TARGET_DIR/src/$FEATURE_NAME"
fi

to_pascal_case() {
  echo "$1" | awk -F'[-_]' '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1' OFS=''
}

to_singular() {
  echo "$1" | sed -E 's/([^s])s$/\1/'
}

SINGULAR_NAME=$(to_singular "$FEATURE_NAME")
UPPER_FEATURE=$(echo "$FEATURE_NAME" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
PASCAL_SINGULAR=$(to_pascal_case "$SINGULAR_NAME")
PASCAL_FEATURE=$(to_pascal_case "$FEATURE_NAME")

echo "=== Scaffolding Multi-Module NestJS Feature: $FEATURE_NAME ==="
echo "Module Root Path: $MODULE_ROOT"

# 1. Create Parent Feature Directories
mkdir -p "$MODULE_ROOT/constants"
mkdir -p "$MODULE_ROOT/dto"
mkdir -p "$MODULE_ROOT/enums"
mkdir -p "$MODULE_ROOT/modules"
mkdir -p "$MODULE_ROOT/repository"
mkdir -p "$MODULE_ROOT/scheduler"
mkdir -p "$MODULE_ROOT/schemas"
mkdir -p "$MODULE_ROOT/services"
mkdir -p "$MODULE_ROOT/types"

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

export const ${UPPER_FEATURE}_VALIDATION_MESSAGES = {
  NAME_REQUIRED: '${PASCAL_SINGULAR} name is required',
  INVALID_STATUS: 'Invalid ${SINGULAR_NAME} status',
} as const;

export const ${UPPER_FEATURE}_DEFAULTS = {
  DEFAULT_PAGE: 1,
  DEFAULT_LIMIT: 10,
} as const;
EOF
  echo "Created: $CONSTANTS_FILE"
fi

# 3. Create Enum File
ENUM_FILE="$MODULE_ROOT/enums/$FEATURE_NAME-status.enum.ts"
if [ ! -f "$ENUM_FILE" ]; then
  cat <<EOF > "$ENUM_FILE"
export enum ${PASCAL_FEATURE}Status {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
  PENDING = 'PENDING',
}
EOF
  echo "Created: $ENUM_FILE"
fi

# 4. Create Schema File
SCHEMA_FILE="$MODULE_ROOT/schemas/$SINGULAR_NAME.schema.ts"
if [ ! -f "$SCHEMA_FILE" ]; then
  cat <<EOF > "$SCHEMA_FILE"
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';
import { ${PASCAL_FEATURE}Status } from '../enums/$FEATURE_NAME-status.enum';

export type ${PASCAL_SINGULAR}Document = HydratedDocument<${PASCAL_SINGULAR}>;

@Schema({ timestamps: true })
export class ${PASCAL_SINGULAR} {
  @Prop({ required: true })
  name: string;

  @Prop()
  description?: string;

  @Prop({ type: String, enum: ${PASCAL_FEATURE}Status, default: ${PASCAL_FEATURE}Status.ACTIVE })
  status: ${PASCAL_FEATURE}Status;
}

export const ${PASCAL_SINGULAR}Schema = SchemaFactory.createForClass(${PASCAL_SINGULAR});
EOF
  echo "Created: $SCHEMA_FILE"
fi

# 5. Create Parent Repository File
REPO_FILE="$MODULE_ROOT/repository/$FEATURE_NAME.repository.ts"
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

  async updateById(id: string, updateData: Partial<${PASCAL_SINGULAR}>): Promise<${PASCAL_SINGULAR} | null> {
    return this.${SINGULAR_NAME}Model
      .findByIdAndUpdate(id, updateData, { returnDocument: 'after' })
      .exec();
  }
}
EOF
  echo "Created: $REPO_FILE"
fi

# 6. Create Parent DTO Files
CREATE_DTO="$MODULE_ROOT/dto/create-$SINGULAR_NAME.dto.ts"
if [ ! -f "$CREATE_DTO" ]; then
  cat <<EOF > "$CREATE_DTO"
import { IsEnum, IsNotEmpty, IsOptional, IsString } from 'class-validator';
import { ${PASCAL_FEATURE}Status } from '../enums/$FEATURE_NAME-status.enum';
import { ${UPPER_FEATURE}_VALIDATION_MESSAGES } from '../constants/$FEATURE_NAME.constants';

export class Create${PASCAL_SINGULAR}Dto {
  @IsString()
  @IsNotEmpty({ message: ${UPPER_FEATURE}_VALIDATION_MESSAGES.NAME_REQUIRED })
  name: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsEnum(${PASCAL_FEATURE}Status, { message: ${UPPER_FEATURE}_VALIDATION_MESSAGES.INVALID_STATUS })
  @IsOptional()
  status?: ${PASCAL_FEATURE}Status;
}
EOF
  echo "Created: $CREATE_DTO"
fi

UPDATE_DTO="$MODULE_ROOT/dto/update-$SINGULAR_NAME.dto.ts"
if [ ! -f "$UPDATE_DTO" ]; then
  cat <<EOF > "$UPDATE_DTO"
import { IsEnum, IsOptional, IsString } from 'class-validator';
import { ${PASCAL_FEATURE}Status } from '../enums/$FEATURE_NAME-status.enum';
import { ${UPPER_FEATURE}_VALIDATION_MESSAGES } from '../constants/$FEATURE_NAME.constants';

export class Update${PASCAL_SINGULAR}Dto {
  @IsString()
  @IsOptional()
  name?: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsEnum(${PASCAL_FEATURE}Status, { message: ${UPPER_FEATURE}_VALIDATION_MESSAGES.INVALID_STATUS })
  @IsOptional()
  status?: ${PASCAL_FEATURE}Status;
}
EOF
  echo "Created: $UPDATE_DTO"
fi

# 7. Create Scheduler File
SCHEDULER_FILE="$MODULE_ROOT/scheduler/$FEATURE_NAME.scheduler.ts"
if [ ! -f "$SCHEDULER_FILE" ]; then
  cat <<EOF > "$SCHEDULER_FILE"
import { Injectable, Logger } from '@nestjs/common';

@Injectable()
export class ${PASCAL_FEATURE}Scheduler {
  private readonly logger = new Logger(${PASCAL_FEATURE}Scheduler.name);

  async handleScheduledTask(): Promise<void> {
    this.logger.log('Executing scheduled maintenance task for ${FEATURE_NAME}...');
  }
}
EOF
  echo "Created: $SCHEDULER_FILE"
fi

# 8. Create Auxiliary Service & Excel Constants
EXCEL_CONSTANTS="$MODULE_ROOT/services/$FEATURE_NAME-excel.constants.ts"
if [ ! -f "$EXCEL_CONSTANTS" ]; then
  cat <<EOF > "$EXCEL_CONSTANTS"
import type * as ExcelJS from 'exceljs';

export const ${UPPER_FEATURE}_EXCEL_SHEET_NAME = '${PASCAL_FEATURE}';

export const ${UPPER_FEATURE}_EXCEL_COLUMNS: Partial<ExcelJS.Column>[] = [
  { header: 'ID', key: 'id', width: 25 },
  { header: 'Name', key: 'name', width: 30 },
  { header: 'Status', key: 'status', width: 15 },
];

export const ${UPPER_FEATURE}_EXCEL_HEADER_STYLE = {
  font: { bold: true },
} as const;
EOF
  echo "Created: $EXCEL_CONSTANTS"
fi

AUX_SERVICE="$MODULE_ROOT/services/export.service.ts"
if [ ! -f "$AUX_SERVICE" ]; then
  cat <<EOF > "$AUX_SERVICE"
import { Injectable } from '@nestjs/common';
import * as ExcelJS from 'exceljs';
import { ${PASCAL_FEATURE}Repository } from '../repository/$FEATURE_NAME.repository';
import {
  ${UPPER_FEATURE}_EXCEL_COLUMNS,
  ${UPPER_FEATURE}_EXCEL_HEADER_STYLE,
  ${UPPER_FEATURE}_EXCEL_SHEET_NAME,
} from './$FEATURE_NAME-excel.constants';

@Injectable()
export class ${PASCAL_FEATURE}ExportService {
  constructor(private readonly ${SINGULAR_NAME}Repository: ${PASCAL_FEATURE}Repository) {}

  async generateReport(): Promise<Buffer> {
    const items = await this.${SINGULAR_NAME}Repository.findAll();
    const workbook = new ExcelJS.Workbook();
    const worksheet = workbook.addWorksheet(${UPPER_FEATURE}_EXCEL_SHEET_NAME);

    worksheet.columns = ${UPPER_FEATURE}_EXCEL_COLUMNS;
    items.forEach((item) => {
      worksheet.addRow(item);
    });

    const headerRow = worksheet.getRow(1);
    headerRow.font = ${UPPER_FEATURE}_EXCEL_HEADER_STYLE.font;

    const uint8Array = await workbook.xlsx.writeBuffer();
    return Buffer.from(uint8Array);
  }
}
EOF
  echo "Created: $AUX_SERVICE"
fi

# 9. Create Parent Service & Controller
SERVICE_FILE="$MODULE_ROOT/$FEATURE_NAME.service.ts"
if [ ! -f "$SERVICE_FILE" ]; then
  cat <<EOF > "$SERVICE_FILE"
import { Injectable, NotFoundException } from '@nestjs/common';
import { ${PASCAL_FEATURE}Repository } from './repository/$FEATURE_NAME.repository';
import { Create${PASCAL_SINGULAR}Dto } from './dto/create-$SINGULAR_NAME.dto';
import { Update${PASCAL_SINGULAR}Dto } from './dto/update-$SINGULAR_NAME.dto';
import { ${PASCAL_SINGULAR} } from './schemas/$SINGULAR_NAME.schema';
import { ${UPPER_FEATURE}_MESSAGES } from './constants/$FEATURE_NAME.constants';

@Injectable()
export class ${PASCAL_FEATURE}Service {
  constructor(private readonly ${SINGULAR_NAME}Repository: ${PASCAL_FEATURE}Repository) {}

  async create(dto: Create${PASCAL_SINGULAR}Dto): Promise<${PASCAL_SINGULAR}> {
    return this.${SINGULAR_NAME}Repository.create(dto);
  }

  async findAll(): Promise<${PASCAL_SINGULAR}[]> {
    return this.${SINGULAR_NAME}Repository.findAll();
  }

  async findOne(id: string): Promise<${PASCAL_SINGULAR}> {
    const item = await this.${SINGULAR_NAME}Repository.findById(id);
    if (!item) {
      throw new NotFoundException(${UPPER_FEATURE}_MESSAGES.NOT_FOUND);
    }
    return item;
  }

  async update(id: string, dto: Update${PASCAL_SINGULAR}Dto): Promise<${PASCAL_SINGULAR}> {
    const updated = await this.${SINGULAR_NAME}Repository.updateById(id, dto);
    if (!updated) {
      throw new NotFoundException(${UPPER_FEATURE}_MESSAGES.NOT_FOUND);
    }
    return updated;
  }
}
EOF
  echo "Created: $SERVICE_FILE"
fi

CONTROLLER_FILE="$MODULE_ROOT/$FEATURE_NAME.controller.ts"
if [ ! -f "$CONTROLLER_FILE" ]; then
  cat <<EOF > "$CONTROLLER_FILE"
import { Controller, Get, Post, Body, Param, Patch } from '@nestjs/common';
import { ${PASCAL_FEATURE}Service } from './$FEATURE_NAME.service';
import { Create${PASCAL_SINGULAR}Dto } from './dto/create-$SINGULAR_NAME.dto';
import { Update${PASCAL_SINGULAR}Dto } from './dto/update-$SINGULAR_NAME.dto';

@Controller('$FEATURE_NAME')
export class ${PASCAL_FEATURE}Controller {
  constructor(private readonly ${SINGULAR_NAME}Service: ${PASCAL_FEATURE}Service) {}

  @Post()
  create(@Body() dto: Create${PASCAL_SINGULAR}Dto) {
    return this.${SINGULAR_NAME}Service.create(dto);
  }

  @Get()
  findAll() {
    return this.${SINGULAR_NAME}Service.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.${SINGULAR_NAME}Service.findOne(id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: Update${PASCAL_SINGULAR}Dto) {
    return this.${SINGULAR_NAME}Service.update(id, dto);
  }
}
EOF
  echo "Created: $CONTROLLER_FILE"
fi

# 10. Process Sub-Modules if provided
if [ -n "$SUBMODULES_CSV" ]; then
  IFS=',' read -ra SUB_ARRAY <<< "$SUBMODULES_CSV"
  for SUB in "${SUB_ARRAY[@]}"; do
    SUB_TRIMMED=$(echo "$SUB" | xargs)
    SUB_SINGULAR=$(to_singular "$SUB_TRIMMED")
    SUB_PASCAL_SINGULAR=$(to_pascal_case "$SUB_SINGULAR")
    SUB_PASCAL_FEATURE=$(to_pascal_case "$SUB_TRIMMED")

    SUB_DIR="$MODULE_ROOT/modules/$SUB_TRIMMED"
    mkdir -p "$SUB_DIR/dto"
    mkdir -p "$SUB_DIR/repository"
    mkdir -p "$SUB_DIR/schemas"

    echo "--- Scaffolding Sub-Module: $SUB_TRIMMED under $SUB_DIR ---"

    # Sub-module schema
    cat <<EOF > "$SUB_DIR/schemas/$SUB_SINGULAR.schema.ts"
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';

export type ${SUB_PASCAL_SINGULAR}Document = HydratedDocument<${SUB_PASCAL_SINGULAR}>;

@Schema({ timestamps: true })
export class ${SUB_PASCAL_SINGULAR} {
  @Prop({ required: true })
  title: string;
}

export const ${SUB_PASCAL_SINGULAR}Schema = SchemaFactory.createForClass(${SUB_PASCAL_SINGULAR});
EOF

    # Sub-module repository
    cat <<EOF > "$SUB_DIR/repository/$SUB_TRIMMED.repository.ts"
import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { ${SUB_PASCAL_SINGULAR}, ${SUB_PASCAL_SINGULAR}Document } from '../schemas/$SUB_SINGULAR.schema';

@Injectable()
export class ${SUB_PASCAL_FEATURE}Repository {
  constructor(
    @InjectModel(${SUB_PASCAL_SINGULAR}.name)
    private readonly model: Model<${SUB_PASCAL_SINGULAR}Document>,
  ) {}

  async findAll(): Promise<${SUB_PASCAL_SINGULAR}[]> {
    return this.model.find().exec();
  }
}
EOF

    # Sub-module DTO
    cat <<EOF > "$SUB_DIR/dto/create-$SUB_SINGULAR.dto.ts"
import { IsNotEmpty, IsString } from 'class-validator';

export class Create${SUB_PASCAL_SINGULAR}Dto {
  @IsString()
  @IsNotEmpty()
  title: string;
}
EOF

    # Sub-module Service
    cat <<EOF > "$SUB_DIR/$SUB_TRIMMED.service.ts"
import { Injectable } from '@nestjs/common';
import { ${SUB_PASCAL_FEATURE}Repository } from './repository/$SUB_TRIMMED.repository';

@Injectable()
export class ${SUB_PASCAL_FEATURE}Service {
  constructor(private readonly repository: ${SUB_PASCAL_FEATURE}Repository) {}

  async findAll() {
    return this.repository.findAll();
  }
}
EOF

    # Sub-module Controller
    cat <<EOF > "$SUB_DIR/$SUB_TRIMMED.controller.ts"
import { Controller, Get } from '@nestjs/common';
import { ${SUB_PASCAL_FEATURE}Service } from './$SUB_TRIMMED.service';

@Controller('$SUB_TRIMMED')
export class ${SUB_PASCAL_FEATURE}Controller {
  constructor(private readonly service: ${SUB_PASCAL_FEATURE}Service) {}

  @Get()
  findAll() {
    return this.service.findAll();
  }
}
EOF

    # Sub-module Module definition (Standard direct import by default)
    cat <<EOF > "$SUB_DIR/$SUB_TRIMMED.module.ts"
import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { ${SUB_PASCAL_FEATURE}Controller } from './$SUB_TRIMMED.controller';
import { ${SUB_PASCAL_FEATURE}Service } from './$SUB_TRIMMED.service';
import { ${SUB_PASCAL_FEATURE}Repository } from './repository/$SUB_TRIMMED.repository';
import { ${SUB_PASCAL_SINGULAR}, ${SUB_PASCAL_SINGULAR}Schema } from './schemas/$SUB_SINGULAR.schema';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: ${SUB_PASCAL_SINGULAR}.name, schema: ${SUB_PASCAL_SINGULAR}Schema }]),
    // Note: Use forwardRef(() => ParentModule) only if a circular dependency incident occurs.
  ],
  controllers: [${SUB_PASCAL_FEATURE}Controller],
  providers: [${SUB_PASCAL_FEATURE}Repository, ${SUB_PASCAL_FEATURE}Service],
  exports: [${SUB_PASCAL_FEATURE}Repository, ${SUB_PASCAL_FEATURE}Service],
})
export class ${SUB_PASCAL_FEATURE}Module {}
EOF

  done
fi

# 11. Create Parent Module File linking sub-modules directly by default
MODULE_FILE="$MODULE_ROOT/$FEATURE_NAME.module.ts"
if [ ! -f "$MODULE_FILE" ]; then
  SUB_MODULE_IMPORT_LINES=""
  SUB_MODULE_CLASS_LIST=""
  SUB_MODULE_EXPORT_LIST=""

  if [ -n "$SUBMODULES_CSV" ]; then
    IFS=',' read -ra SUB_ARRAY <<< "$SUBMODULES_CSV"
    for SUB in "${SUB_ARRAY[@]}"; do
      SUB_TRIMMED=$(echo "$SUB" | xargs)
      SUB_PASCAL_FEATURE=$(to_pascal_case "$SUB_TRIMMED")
      SUB_MODULE_IMPORT_LINES="${SUB_MODULE_IMPORT_LINES}import { ${SUB_PASCAL_FEATURE}Module } from './modules/$SUB_TRIMMED/$SUB_TRIMMED.module';\n"
      SUB_MODULE_CLASS_LIST="${SUB_MODULE_CLASS_LIST}    ${SUB_PASCAL_FEATURE}Module,\n"
      SUB_MODULE_EXPORT_LIST="${SUB_MODULE_EXPORT_LIST}    ${SUB_PASCAL_FEATURE}Module,\n"
    done
  fi

  cat <<EOF > "$MODULE_FILE"
import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { ${PASCAL_FEATURE}Controller } from './$FEATURE_NAME.controller';
import { ${PASCAL_FEATURE}Service } from './$FEATURE_NAME.service';
import { ${PASCAL_FEATURE}Repository } from './repository/$FEATURE_NAME.repository';
import { ${PASCAL_SINGULAR}, ${PASCAL_SINGULAR}Schema } from './schemas/$SINGULAR_NAME.schema';
import { ${PASCAL_FEATURE}Scheduler } from './scheduler/$FEATURE_NAME.scheduler';
import { ${PASCAL_FEATURE}ExportService } from './services/export.service';
$(echo -e "$SUB_MODULE_IMPORT_LINES")
@Module({
  imports: [
    MongooseModule.forFeature([{ name: ${PASCAL_SINGULAR}.name, schema: ${PASCAL_SINGULAR}Schema }]),
$(echo -e "$SUB_MODULE_CLASS_LIST")  ],
  controllers: [${PASCAL_FEATURE}Controller],
  providers: [
    ${PASCAL_FEATURE}Repository,
    ${PASCAL_FEATURE}Service,
    ${PASCAL_FEATURE}Scheduler,
    ${PASCAL_FEATURE}ExportService,
  ],
  exports: [
    ${PASCAL_FEATURE}Repository,
    ${PASCAL_FEATURE}Service,
    ${PASCAL_FEATURE}ExportService,
$(echo -e "$SUB_MODULE_EXPORT_LIST")  ],
})
export class ${PASCAL_FEATURE}Module {}
EOF
  echo "Created: $MODULE_FILE"
fi

echo "=== Multi-Module NestJS Feature $FEATURE_NAME scaffolded successfully ==="
