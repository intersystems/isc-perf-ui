export * from './default.service';
import { DefaultService } from './default.service';
export * from './monitor.service';
import { MonitorService } from './monitor.service';
export const APIS = [DefaultService, MonitorService];
