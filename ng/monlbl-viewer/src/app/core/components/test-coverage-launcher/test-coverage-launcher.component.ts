import { Component } from '@angular/core';
import { FormBuilder, FormControl } from '@angular/forms';
import { CoverageRestService } from '../../services/coverage-rest.service';

@Component({
  selector: 'app-test-coverage-launcher',
  templateUrl: './test-coverage-launcher.component.html',
  styleUrls: ['./test-coverage-launcher.component.css']
})
export class TestCoverageLauncherComponent {
  constructor(
    private formBuilder: FormBuilder,
    private covRestService: CoverageRestService
  ) {
    
  }
    dataForm = this.formBuilder.group({
      UnitTestRoot: '',
      CoverageLevel: 1,
      CoverageClasses: '',
      CoverageRoutines: '',
      PidList: '',
      Timing: 0,
    });
    timingsList: Number[] = [0, 1];
    CoverageLevels: Number[] = [0, 1, 2, 3];
    onSubmit() 
    {
      console.log("hello world?");
      console.log(this.dataForm.value);
      this.covRestService.Start(this.dataForm.value).subscribe(() => {
        this.covRestService.GetResults("TestCoverage.Data.CodeUnit.CLS", "all tests").subscribe((results) => {
          console.log("Results received:", results);
          // Update your component state here with the results
        });
      });
      this.dataForm.reset();
    }
}
