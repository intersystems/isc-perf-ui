import { ComponentFixture, TestBed } from '@angular/core/testing';

import { TestCoverageLauncherComponent } from './test-coverage-launcher.component';

describe('TestCoverageLauncherComponent', () => {
  let component: TestCoverageLauncherComponent;
  let fixture: ComponentFixture<TestCoverageLauncherComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [TestCoverageLauncherComponent]
    });
    fixture = TestBed.createComponent(TestCoverageLauncherComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
