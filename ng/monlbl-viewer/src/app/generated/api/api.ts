export * from './coverage.service';
import { CoverageService } from './coverage.service';
export * from './default.service';
import { DefaultService } from './default.service';
export * from './monitor.service';
import { MonitorService } from './monitor.service';
export const APIS = [CoverageService, DefaultService, MonitorService];
