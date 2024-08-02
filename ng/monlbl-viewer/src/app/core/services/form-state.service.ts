import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class FormStateService {
  private formData: any = null;

  setFormData(data: any): void {
    this.formData = data;
  }

  getFormData(): any {
    return this.formData;
  }

  clearFormData(): void {
    this.formData = null;
  }
}
