import { TestBed } from '@angular/core/testing';

import { CoverageRestService } from './coverage-rest.service';

describe('CoverageRestService', () => {
  let service: CoverageRestService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(CoverageRestService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
