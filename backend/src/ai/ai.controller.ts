import { Controller, Post, Body, UseGuards, Req } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { AiService } from './ai.service';
import { IsArray, ValidateNested, IsString, IsEnum } from 'class-validator';
import { Type } from 'class-transformer';

class MessageDto {
  @IsEnum(['user', 'assistant']) role: 'user' | 'assistant';
  @IsString() content: string;
}
class ChatDto {
  @IsArray() @ValidateNested({ each: true }) @Type(() => MessageDto)
  messages: MessageDto[];
}

@Controller('ai')
@UseGuards(AuthGuard('jwt'))
export class AiController {
  constructor(private readonly svc: AiService) {}

  @Post('chat')
  chat(@Req() req: any, @Body() dto: ChatDto) {
    return this.svc.chat(req.user.businessId, dto.messages);
  }
}
