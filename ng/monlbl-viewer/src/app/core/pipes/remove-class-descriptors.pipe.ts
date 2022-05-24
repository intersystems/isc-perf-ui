import { Pipe, PipeTransform } from '@angular/core';

@Pipe({name: 'removeClassDescriptors'})
export class RemoveClassDescriptorsPipe implements PipeTransform {
  transform(value: any[]): any[] {
    return value.filter((value: string, index, array) => {
      return value.slice(-1) !== '0';
    }).sort((a, b) => a.localeCompare(b));
  }
}
