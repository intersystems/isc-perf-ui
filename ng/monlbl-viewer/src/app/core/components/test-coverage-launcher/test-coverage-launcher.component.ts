import { Component } from '@angular/core';
import { FormBuilder } from '@angular/forms';

@Component({
  selector: 'app-test-coverage-launcher',
  templateUrl: './test-coverage-launcher.component.html',
  styleUrls: ['./test-coverage-launcher.component.css']
})
export class TestCoverageLauncherComponent {
  constructor(
    private formBuilder: FormBuilder
  ) {
    
  }

    onSubmit(data: any) 
    {
      console.log("hello world?")
    }
}
